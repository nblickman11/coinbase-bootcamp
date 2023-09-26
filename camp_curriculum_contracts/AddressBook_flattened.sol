
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/AddressBook.sol


pragma solidity ^0.8.17;


contract AddressBook is Ownable {

    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
    }

    mapping(uint => Contact) public contacts;
    mapping(uint=>bool) public idExists;
    // These Id's wont get deleted.
    uint[] public allIds;

    error ContactNotFound(uint);

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    function addContact(uint _id, string memory _firstName, string memory _lastName,
     uint[] memory _phoneNumbers) public onlyOwner {
        
        Contact memory inst = Contact(_id, _firstName, _lastName, _phoneNumbers);
        contacts[_id] = inst;
        idExists[_id] = true;
        allIds.push(_id);
    }

    function deleteContact(uint _id) public onlyOwner {
        if (idExists[_id] == false) {
            revert ContactNotFound(_id);
        }
        delete contacts[_id];
        delete idExists[_id];
    }

    function getContact(uint _id) public view returns(Contact memory){
        if (idExists[_id] == false) {
            revert ContactNotFound(_id);
        }
        return contacts[_id];
    }

    function getAllContacts() public view returns(Contact[] memory) {
        
        uint size = getExistingIndexsLength();
        uint allContactsCounter = 0;

        Contact[] memory allContacts = new Contact[](size);
      
        for (uint i=0; i<allIds.length; i++) {
            if (idExists[allIds[i]] == true) {
                allContacts[allContactsCounter] = contacts[allIds[i]];
                allContactsCounter++;
            }
        }
        return allContacts;
    }

    function getExistingIndexsLength() internal view returns(uint){
        uint size = 0;
        for (uint i=0; i<allIds.length; i++) {
            if (idExists[allIds[i]] == true) {
                size++;
            }
        }
        return size;
    }
}    

contract AddressBookFactory {

    function deploy() public returns (address) {
        AddressBook newContract = new AddressBook(msg.sender);
        return address(newContract);
    }
}
