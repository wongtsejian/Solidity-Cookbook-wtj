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
    owner = msg.sender;
    console.log("SimpleProxy Constructor owner: %s, Implementation: %s", owner, Implementation);
  }

  /**
    * @dev Override parent function to specify
    */
  function _implementation() internal view override returns (address) {
    console.log(" _implementation: %s", Implementation);
    return Implementation;
  }

  function getImplementation() view public returns (address) { 
    return _implementation();
  }

  function setImplementation(address _address) public  {
    require(msg.sender == owner, "Invalid Owner");
    console.log(" setImplementation: %s, address: %s", Implementation, _address);
    Implementation = _address ; 
    console.log(" Implementation: %s set to address: %s", Implementation, _address);
  }


//  function _beforeFallback() internal virtual override {
//   console.log("before fallback: implementation: ", Implementation);
//  }
}