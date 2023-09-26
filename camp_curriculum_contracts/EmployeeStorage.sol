// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract EmployeeStorage {

    uint24 private salary;
    uint16 private shares;
    string public name;
    uint256 public idNumber;

    error TooManyShares(uint256 potentialShares);

    constructor(uint16 _shares, string memory _name, uint24 _salary, uint256 _idNumber) {
        shares = _shares;
        name = _name;
        salary = _salary;
        idNumber = _idNumber;
    }

    function viewSalary() external view returns(uint24) {
        return salary;
    }
    
    function viewShares() external view returns(uint16) {
        return shares;
    }

    function grantShares(uint16 _newShares) public {
        
        uint16 potentialShares = shares + _newShares;
        
        if (_newShares > 5000) {
            revert("Too many shares");
        }
        else if (potentialShares > 5000) {
            revert TooManyShares(potentialShares);
        }
        else {
            shares = potentialShares;
        }
    }
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload (_slot)
        }
    }

    function debugResetShares() public {
        shares = 1000;
    }
}