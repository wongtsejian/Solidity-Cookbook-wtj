// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Proxy.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

// study https://medium.com/coinmonks/proxy-pattern-and-upgradeable-smart-contracts-45d68d6f15da to understand
// the need for storage slot
library StorageSlot {
    function getAddressAt(bytes32 slot) internal view returns (address a) {
        assembly {
            a := sload(slot)
        }
    }

    function setAddressAt(bytes32 slot, address address_) internal {
        assembly {
            sstore(slot, address_)
        }
    }
}

// objective of this proxy is quickly show an example of how to use the 
// Proxy.sol abstract class from openzepplin. 
// For production use case, consider using ERC1967Proxy, TransparentUpgradeableProxy
contract SimpleProxy is Proxy {

  address public Implementation;
  address owner; 
   bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

  constructor() {
    owner = msg.sender;
    console.log("SimpleProxy Constructor owner: %s, Implementation: %s", owner, Implementation);
  }

  /**
    * @dev Override parent function to specify
    */
  function _implementation() internal view override returns (address) {
    // console.log(" _implementation: %s", Implementation);
    // return Implementation;
    return StorageSlot.getAddressAt(_IMPL_SLOT);
  }

  function getImplementation() view public returns (address) { 
    return _implementation();
  }

  function setImplementation(address _address) public  {
    require(msg.sender == owner, "Invalid Owner");
    // console.log(" setImplementation: %s, address: %s", Implementation, _address);
    Implementation = _address ; 
    StorageSlot.setAddressAt(_IMPL_SLOT, _address);
    // console.log(" Implementation: %s set to address: %s", Implementation, _address);
  }


//  function _beforeFallback() internal virtual override {
//   console.log("before fallback: implementation: ", Implementation);
//  }
}