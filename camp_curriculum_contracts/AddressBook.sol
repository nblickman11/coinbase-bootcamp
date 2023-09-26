// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

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
