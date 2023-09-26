


// POSSIBLE ORACLES
// OK, I should go to Chainlink, and use one of it's requests to grab
// data from BLS: https://www.bls.gov/cpi/latest-numbers.htm


// Benefits:Inflation Hedge: Cryptocurrencies tracking CPI can act as a hedge against 
//inflation. If the CPI increases, the cryptocurrency's value should 
//also increase, helping users preserve their purchasing 
//power in an environment where traditional fiat currencies may be
// losing value due to inflation.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Import the interface for the CPI oracle
import "./CPIOracleInterface.sol";

contract CPIToken is ERC20, Ownable {
    // The name and symbol of the token
    string private _name = "CPIToken";
    string private _symbol = "CPI";
    
    // Number of decimal places for token
    uint8 private _decimals = 18;
    
    // Address of the CPI oracle contract
    address public oracleAddress;

    // Constructor to initialize the token with an initial supply
    constructor(uint256 initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, initialSupply * (10 ** uint256(_decimals)));
        oracleAddress = _oracleAddress;
    }
    
    // Modifier to ensure that only the oracle can call certain functions
    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Only the oracle can call this function");
        _;
    }

    // Function to update the CPI value (only callable by the oracle)
    function updateCPI(uint256 newCPI) external onlyOracle {
        // Update the CPI value in the contract
        // You may want to add additional logic here to handle how CPI affects your token supply
        // For simplicity, we'll just update a state variable here
        // In a real implementation, you'd likely have more complex logic
        // that adjusts the token supply based on CPI changes
        // For example, you might mint new tokens if CPI increases and burn tokens if CPI decreases
        // This is just a basic example to illustrate the concept
        _cpiValue = newCPI;
    }
    
    // Internal variable to store the current CPI value
    uint256 private _cpiValue;

    // Function to get the current CPI value
    function getCPI() public view returns (uint256) {
        return _cpiValue;
    }


    // Mint new tokens (only the owner can call this function)
    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount * (10 ** uint256(_decimals)));
    }
    
    // Burn tokens (only the owner can call this function)
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount * (10 ** uint256(_decimals)));
    }
}
