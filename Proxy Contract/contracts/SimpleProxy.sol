// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Proxy.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

// objective of this proxy is quickly show an example of how to use the 
// Proxy.sol abstract class from openzepplin. 
// For production use case, consider using ERC1967Proxy, TransparentUpgradeableProxy
contract SimpleProxy is Proxy {

  address public Implementation;
  address owner; 

  constructor() {
    this.owner = msg.sender;
    console.log("hello world");
  }

  /**
    * @dev Override parent function to specify
    */
  function _implementation() internal view virtual returns (address) {
    return this.Implementation;
  }

  function setImplementation(address _address) external {
    require(msg.sender == this.owner, "Invalid Owner");
    this.Implementation = _address ; 
  }

}