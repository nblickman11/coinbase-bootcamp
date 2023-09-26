// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract UnburnableToken {

    mapping(address => uint) public balances;
    uint public totalSupply;
    uint public totalClaimed;
    mapping(address => bool) public claimed;
    
    error TokensClaimed();
    error AllTokensClaimed();
    error UnsafeTransfer(address);

    constructor() {
        totalSupply = 1000000000;
    }

    function claim() public {
        if (totalSupply == 0) {
            revert AllTokensClaimed();
        }
        else if (claimed[msg.sender] == true) {
            revert TokensClaimed();
        }
        // Else there's a token a supply and a user has not made a claim yet.
        else {
            totalSupply -= 1000;
            totalClaimed += 1000;
            balances[msg.sender] = balances[msg.sender] + 1000;
            claimed[msg.sender] = true;
        }
    }

    function safeTransfer(address _to, uint _amount) public {
        if (_to == address(0) || _to.balance <= 0) {
            revert UnsafeTransfer(_to);
        }
        else {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
        }
    }


}