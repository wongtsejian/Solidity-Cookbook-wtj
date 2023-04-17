// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract ProxyImplementation {
  uint public number;

  function setNumber(uint _number) external {
    console.log("setNumber: %s", _number);
    number = _number ;
    console.log("Done setNumber: %s", number);
  }

  function getNumber() external view returns(uint){
    console.log("getNumber: %s", number);
    return number;
  }
}