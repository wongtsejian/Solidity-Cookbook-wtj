// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract SimpleStorage {
    uint public storedData;

    address public caller;

    constructor() payable{
    }

    receive() payable external{

    }
    fallback() payable external{

    }

    function set(uint x) public {
        caller = msg.sender;
        storedData = x;
    }
}