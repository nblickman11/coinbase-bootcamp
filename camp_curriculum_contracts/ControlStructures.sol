// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ControlStructures {

    error AfterHours(uint _time);

    function fizzBuzz(uint _number) external pure returns(string memory) {
        
        if (_number % 3 == 0 && _number % 5 == 0) {
            return "FizzBuzz";
        }
        else if (_number % 3 == 0) {
            return "Fizz";
        }
        else if (_number % 5 == 0) {
            return "Buzz";
        }
        else {
            return "Splat";
        }
    } 
    
    function doNotDisturb(uint _time) external pure returns(string memory) {
              
       assert(_time < 2400);
       if (1200 <= _time && _time <= 1259) { // Bootcamp instructions probably means 1299, not 1259.
            revert("At lunch!");
        }
        else if (800 <= _time && _time <= 1199) {
            return "Morning!";
        }
        else if (1300 <= _time && _time <= 1799) {
            return "Afternoon!";
        }
        else if (1800 <= _time && _time <= 2199) {
            return "Evening!";
        }
        else { // Time is less than 800 or greater than 2200 
            revert AfterHours(_time);
        } 
    } 
}
