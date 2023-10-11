// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/INUONController.sol";
import "../interfaces/INLP.sol";
import "../interfaces/INUON.sol";

/**
 * @notice The Collateral Hub (CHub) is receiving collaterals from users, and mint them back NUON according to the collateral ratio defined in the NUON Controller
 * @dev (Driiip) TheHashM
 * @author This Chub is designed by Gniar & TheHashM
 */

// NELSON NOTE: we don't include a reentrancy security library.
// contract CollateralHubV3 is OwnableUpgradeable {
//     using Math for uint256;

contract CollateralHubV3 {
    using SafeMath for uint256;
    /**
     * @dev Contract instances.
     */
    address public NUONController;
    address public Treasury;
    address public NUON;
    address public NuonOracleAddress;
    address public ChainlinkOracle;
    address public TruflationOracle;
    address public collateralUsed;
    address public unirouter;
    address public lpPair;
    address public NLP;
    address public Relayer;
    address public USDT;

    /**
     * @notice Contract Data : mapping and infos
     */
    mapping(uint256 => bool) public vaultsRedeemPaused;
    mapping(address => uint256) public usersIndex;
    mapping(address => uint256) public usersAmounts;
    mapping(address => uint256) public mintedAmount;
    mapping(address => uint256) public userLPs;
    mapping(address => bool) public nlpCheck;
    mapping(address => uint256) public nlpPerUser;

    address[] public users;
    address[] public collateralToNuonRoute;
    address[] public collateralToPairRoute;
    uint256 public liquidationFee;
    uint256 public minimumDepositAmount;
    uint256 public liquidityBuffer;
    uint256 public liquidityCheck;
    uint256 public maxNuonBurnPercent;
    uint256 public constant MAX_INT = 2 ** 256 - 1;
    uint256 public assetMultiplier;
    uint256 public decimalDivisor;
    uint256 public count;

    /**
     * @notice Events.
     */
    event First3RequiresPassed(string);

    event MintedNUON(
        address indexed user,
        uint256 NUONAmountD18,
        uint256 NuonPrice,
        uint256 collateralAmount
    );
    event Redeemed(
        address indexed user,
        uint256 fullAmount,
        uint256 NuonAmount
    );
    event depositedWithoutMint(
        address indexed user,
        uint256 fees,
        uint256 depositedAmount
    );
    event mintedWithoutDeposit(
        address indexed user,
        uint256 mintedAmount,
        uint256 collateralRequired
    );
    event redeemedWithoutNuon(
        address indexed user,
        uint256 fees,
        uint256 amountSentToUser
    );
    event burnedNuon(address indexed user, uint256 burnedAmount);

    function initialize(uint256 _assetMultiplier) public {
        assetMultiplier = _assetMultiplier;
    }

    // /**
    //  * @notice Sets the core addresses used by the contract
    //  * @param _treasury Treasury contract
    //  * @param _controller NUON controller
    //  */
    function setCoreAddresses(
        address _controller,
        address _NLP,
        address _NUON
    ) public {
        NUONController = _controller;
        NLP = _NLP;
        NUON = _NUON;
    }

    /**
     * @notice A series of view functions to return the contract status.  For front end people.
     */
    function viewUserCollateralAmount(
        address _user
    ) public view returns (uint256) {
        return (usersAmounts[_user]);
    }

    /**
     * @notice Used to mint NUON as a user deposit collaterals
     * return The minted NUON amount
     * @dev collateralAmount is in USDT
     */

    // think _amount is in wei of the WETH
    function mint(
        uint256 _collateralRatio,
        uint256 _amount
    ) external returns (uint256) {
        require(
            INUONController(NUONController).isMintPaused() == false,
            "CHUB: Minting paused!"
        );

        //cratio has to be bigger than the minimum required in the controller, otherwise user can get liquidated instantly
        //It has to be lower because lower means higher % cratio
        require(
            _collateralRatio <=
                INUONController(NUONController).getGlobalCollateralRatio(
                    address(this)
                ),
            "Collateral Ratio out of bounds"
        );
        require(
            _collateralRatio >=
                INUONController(NUONController).getMaxCratio(address(this)),
            "Collateral Ratio too low"
        );
        emit First3RequiresPassed("First3RequiresPassed");

        // If user is new, add them.
        if (usersAmounts[msg.sender] == 0) {
            usersIndex[msg.sender] = users.length;
            users.push(msg.sender);
            // Make sure the owner of contract can't create positions I think.
            //if (msg.sender != owner()) {
            require(
                nlpCheck[msg.sender] == false,
                "You already have a position"
            );
            //just used to increment new NFT IDs
            uint256 newItemId = count;
            count++;
            INLP(NLP).mintNLP(msg.sender, newItemId);
            INLP(NLP)._createPosition(msg.sender, newItemId);
            nlpCheck[msg.sender] = true;
            nlpPerUser[msg.sender] = newItemId;
            //}
        }
        //In case the above if statement isnt executed we need to instantiate the
        //storage element here to update the position status
        uint256 collateralAmount = _amount;
        require(
            collateralAmount > minimumDepositAmount,
            "Please deposit more than the min required amount"
        );
        (
            uint256 NUONAmountD18,
            ,
            uint256 collateralAmountAfterFees,
            uint256 collateralRequired
        ) = estimateMintedNUONAmount(collateralAmount, _collateralRatio);
        uint256 userAmount = usersAmounts[msg.sender];
        usersAmounts[msg.sender] = userAmount.add(collateralAmountAfterFees);
        mintedAmount[msg.sender] = mintedAmount[msg.sender].add(NUONAmountD18);
        // if (msg.sender != owner()) {

        //NOT SURE what contract this collateralUsed address is.
        // function sends tokens from user to this contract, as being POTENTIALLY
        // burnable
        // IERC20Burnable(collateralUsed).transferFrom(
        //     msg.sender,
        //     address(this),
        //     _amount.add(collateralRequired)
        // );
        //_addLiquidity involves adding liquidity to a UNISWAP pool with NUON and USDT
        //_addLiquidity(collateralRequired);

        INLP(NLP)._addAmountToPosition(
            mintedAmount[msg.sender],
            usersAmounts[msg.sender],
            userLPs[msg.sender],
            nlpPerUser[msg.sender]
        );
        // } else {
        //     IERC20Burnable(collateralUsed).transferFrom(
        //         msg.sender,
        //         address(this),
        //         _amount
        //     );
        // }

        // NOT SURE: where this Treasury contract is.
        // IERC20Burnable(collateralUsed).transfer(
        //     Treasury,
        //     collateralAmount.sub(collateralAmountAfterFees)
        // );

        // CALLING mint() which is in the Parent of Nuon (ERC 20)
        INUON(NUON).mint(msg.sender, NUONAmountD18);
        emit MintedNUON(
            msg.sender,
            NUONAmountD18,
            getTargetPeg(),
            collateralAmount
        );
        return NUONAmountD18;
    }

    /**
     * @notice A view function to estimate the amount of NUON out. For front end people.
     * @param collateralAmount The amount of collateral that the user wants to use
     * return The NUON amount to be minted, the minting fee in d18 format, and the collateral to be deposited after the fees have been taken
     */
    function estimateMintedNUONAmount(
        uint256 collateralAmount,
        uint256 _collateralRatio
    ) public view returns (uint256, uint256, uint256, uint256) {
        require(
            _collateralRatio <=
                INUONController(NUONController).getGlobalCollateralRatio(
                    address(this)
                ),
            "Collateral Ratio out of bounds"
        );
        require(
            _collateralRatio >=
                INUONController(NUONController).getMaxCratio(address(this)),
            "Collateral Ratio too low"
        );
        require(
            collateralAmount > minimumDepositAmount,
            "Please deposit more than the min required amount"
        );
        // PROB OFF: collateralAmount50*10E18 - (collateralAmount50*10E18 * .05fee / 100 / 1e18)
        uint256 collateralAmountAfterFees = collateralAmount.sub(
            collateralAmount
                .mul(
                    INUONController(NUONController).getMintingFee(address(this))
                )
                .div(100)
                .div(1e18)
        );

        uint256 collateralAmountAfterFeesD18 = collateralAmountAfterFees *
            assetMultiplier;

        uint256 NUONAmountD18;

        NUONAmountD18 = calcOverCollateralizedMintAmounts(
            _collateralRatio,
            getCollateralPrice(),
            collateralAmountAfterFeesD18
        );

        // LINE below streams off into many more calculations. So for now do:
        uint256 collateralRequired = 10;
        //(uint256 collateralRequired, ) = mintLiquidityHelper(NUONAmountD18);

        return (
            NUONAmountD18,
            INUONController(NUONController).getMintingFee(address(this)),
            collateralAmountAfterFees,
            collateralRequired
        );
    }

    /**
     * @notice A view function to get the collateral price of an asset directly on chain
     * return The asset price
     */
    function getCollateralPrice() public view returns (uint256) {
        return 25;
        //uint256 assetPrice = IChainlinkOracle(ChainlinkOracle).latestAnswer().mul(1e10);
        //return assetPrice;
    }

    /**
     * @notice View function used to compute the amount of NUON to be minted
     * @param collateralRatio Determined by the controller contract
     * @param collateralPrice Determined by the assigned oracle
     * @param collateralAmountD18 Collateral amount in d18 format
     * return The NUON amount to be minted
     */
    function calcOverCollateralizedMintAmounts(
        uint256 collateralRatio,
        uint256 collateralPrice,
        uint256 collateralAmountD18
    ) internal view returns (uint256) {
        uint256 collateralValue = (collateralAmountD18.mul(collateralPrice))
            .div(1e18);
        uint256 NUONValueToMint = collateralValue.mul(collateralRatio).div(
            1
            //ITruflation(TruflationOracle).getNuonTargetPeg()
        );
        return NUONValueToMint;
    }

    function getTargetPeg() public view returns (uint256) {
        return 1;
        //uint256 peg = ITruflation(TruflationOracle).getNuonTargetPeg();
        //return peg;
    }
}
