// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract GarageManager {

    mapping(address => Car[]) public garage;
    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }
    error BadCarIndex(uint);

    // // Instantiate a new car and add it to your mapping. 
    function addCar(string memory _make, string memory _model,
     string memory _color, uint _numberOfDoors) external 
     {
        Car memory carInst = Car(_make, _model, _color, _numberOfDoors);
        garage[msg.sender].push(carInst);
     }

    // // Return a list of your cars in your storage mapping.
    function getMyCars() external view returns(Car[] memory) {
        Car[] memory userCars = new Car[](garage[msg.sender].length);
        for (uint i=0; i<userCars.length; i++){
            userCars[i] = garage[msg.sender][i];
        }
        return userCars;
    }

    function getUserCars(address addr) external view returns(Car[] memory) {
        Car[] memory userCars = new Car[](garage[addr].length);
        for (uint i=0; i<userCars.length; i++){
            userCars[i] = garage[addr][i];
        }
        return userCars;
    }

     function updateCar(uint _index, string memory _make, string memory _model,
      string memory _color, uint _numberOfDoors) external 
      {
          // If the given index is out of bounds of your array of cars, revert.
          if (_index >= garage[msg.sender].length) {
              revert BadCarIndex(_index);
          }
          // Otherwise, create a new car and update your list at the specified index.
          else {
              Car memory carInst = Car(_make, _model, _color, _numberOfDoors);
              garage[msg.sender][_index] = carInst;
          }
      }

    function resetMyGarage() external {
        delete garage[msg.sender];
    }

}