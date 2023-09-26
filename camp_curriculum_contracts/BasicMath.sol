// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract BasicMath {

    function adder(uint _a, uint _b) public pure returns(uint, bool) {
        /*
            Initialze variables inside temporary memory, as it's cheaper than persistent storage.
            The default values for sum and error are 0 and false.
        */
        uint sum; 
        bool error;
        /*
            If there is an overflow, return an error of true.
            Checking our value with "unchecked" won't detect overflow. Also, adding values
            that overflow will cause a revert, but we want to return an error value.  Hence,
            we check for overflow through the subtraction below.
        */
        if ((type(uint).max - _a) < _b) {
            error = true;
        }
        else {
            sum = _a + _b;
        }
        return (sum, error);
    }

    function subtractor(uint _a, uint _b) public pure returns(uint, bool) {
        uint difference; 
        bool error;
        // If there is an underflow, return an error of true.
        if (_a < _b) {
            error = true;
        }
        else {
            difference = _a - _b;
        }
        return (difference, error);
    }
}
