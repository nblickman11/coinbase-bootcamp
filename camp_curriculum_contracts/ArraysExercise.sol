// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
//import "hardhat/console.sol";

contract ArraysExercise {
    
    uint[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] public senders;
    uint[] public timestamps;

    function getNumbers() external view returns(uint[] memory) {
        // Set the memory array to be the same size as the current storage array.
        uint[] memory result = new uint[](numbers.length);
        for (uint index = 0; index < numbers.length; index++) {
            result[index] = numbers[index];
        }
        return result;
    }

    function resetNumbers() public {
        numbers = [1,2,3,4,5,6,7,8,9,10];
    }

    function appendToNumbers(uint[] calldata _toAppend) external {
        for(uint index=0; index<_toAppend.length; index++){
            numbers.push(_toAppend[index]);
        }
    }

    function saveTimestamp(uint _unixTimestamp) external {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);
    }

    function afterY2K() external view returns(uint[] memory, address[] memory) {
        uint size = countStamps();
        // Set our memory arrays to be the size of the "filtered" storage array.
        uint[] memory filteredTimestamps = new uint[](size);
        address[] memory filteredSenders = new address[](size);
        
        // Loop through the entire storage array, and add it's filtered elements to the memory array.
        uint filteredTimestampsIndex = 0;
        for(uint index=0; index<timestamps.length; index++) {
            if (timestamps[index] > 946702800) {
                filteredTimestamps[filteredTimestampsIndex] = timestamps[index];
                filteredSenders[filteredTimestampsIndex] = senders[index];
                filteredTimestampsIndex++;
            }
        }
        return (filteredTimestamps, filteredSenders);
    }

    function countStamps() internal view returns(uint) {
        uint counter;
        for(uint index=0; index<timestamps.length; index++) {
            if (timestamps[index] > 946702800) {
                counter++;
            }
        }
        return counter;
    }

    function resetTimestamps() public {
        // Delete all elements inside of the array.
        delete timestamps;
    } 

    function resetSenders() public {
        delete senders;
    } 

}