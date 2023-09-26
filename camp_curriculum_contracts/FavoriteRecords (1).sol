// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FavoriteRecords {

    mapping(string => bool) public approvedRecords;
    mapping(address => mapping(string => bool)) public userFavorites;
    // Array structure is for iterable lookup.
    mapping(address => string[]) public userFavoritesArray;
    
    error NotApproved(string);

    string[] public initRecords;

    constructor() {
        // It is cheaper to put records in memory. 
        initRecords = ["Thriller","Back in Black","The Bodyguard",
        "The Dark Side of the Moon","Their Greatest Hits (1971-1975)",
        "Hotel California","Come On Over","Rumours","Saturday Night Fever"];
        
        for (uint8 i=0; i<initRecords.length; i++) {
            approvedRecords[initRecords[i]] = true;
        }
    } 

    function getApprovedRecords() external view returns(string[] memory) {
        // It is cheaper to put records in memory. 
        return initRecords;
    }

    function addRecord(string memory albumName) external {
        // Confirm the record's approved and that it's not already included in favorites.
        if (approvedRecords[albumName] == true && userFavorites[msg.sender][albumName] == false) {
            userFavorites[msg.sender][albumName] = true;
            userFavoritesArray[msg.sender].push(albumName);
        }
        // If album not approved (key not found), Solidity uses default of the data type.
        else if (approvedRecords[albumName] == false) { 
            revert NotApproved(albumName);
        }
        else {
            // If the record's approved, but already included in favorites, do nothing.
        }
    }

    function getUserFavorites(address userAddress) public view returns(string[] memory) 
    {
        return userFavoritesArray[userAddress];
    }
    // {
    //     string[] memory inMemArray = new string[](userFavoritesArray[userAddress].length);
    //     for (uint8 i=0; i<userFavoritesArray[userAddress].length; i++) {
    //         inMemArray[i] = userFavoritesArray[userAddress][i];
    //     }
    //     return inMemArray;
    // }

    function resetUserFavorites() external {
        // Have to delete elements of a mapping one by one. Use our array to help us.
        string[] memory currentFavorites = userFavoritesArray[msg.sender];
        for (uint i=0; i<currentFavorites.length; i++) {
            userFavorites[msg.sender][currentFavorites[i]] = false;
        }
        // Can remove all elements of a "dynamic" array.
        delete userFavoritesArray[msg.sender];
    }
}