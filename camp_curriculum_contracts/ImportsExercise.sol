// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./SillyStringUtils.sol";

contract ImportsExercise {

    using SillyStringUtils for SillyStringUtils.Haiku;

    // To use the shruggie function, we need to call to call it on it's Datatype!
    using SillyStringUtils for string;

    // Think haiku getting set with default "" values here.
    SillyStringUtils.Haiku public haiku;

    function saveHaiku(string memory line1, string memory line2, string memory line3) public {
        haiku.line1 = line1;
        haiku.line2 = line2;
        haiku.line3 = line3;
    }

    function getHaiku() public view returns(SillyStringUtils.Haiku memory) {
        return haiku;
    }

    function shruggieHaiku() public view returns(SillyStringUtils.Haiku memory) {
        SillyStringUtils.Haiku memory newHaiku; 
        newHaiku.line1 = haiku.line1;
        newHaiku.line2 = haiku.line2;

        //haiku.line3 is string data type passed as first parameter to shruggie.
        newHaiku.line3 = haiku.line3.shruggie();
        return newHaiku;
    }
}

