// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VictorXSGD is ERC20 {
    constructor() ERC20("victorXSGD", "XSGDVIC1") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function haha() view public returns (uint256) {
        console.log("calling haha");
        return 123;
    }
}
