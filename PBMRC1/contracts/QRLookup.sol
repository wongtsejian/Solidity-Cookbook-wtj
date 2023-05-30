/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
pragma solidity 0.8.18;

contract QRLookup {
    
    address[] private owners;
    address[] private acquirers;
    //mapping maps address of acquirer to a mapping of a hash of the QR_dest_info to the address of the merchant
    mapping (address => mapping(bytes32 => address)) private lookup;
    
    constructor() {
        owners.push(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender),"Error: Non-owners cannot call this function");
        _;
    }

    modifier onlyAcquirer() {
        require(isAcquirer(msg.sender),"Error: Non-acquirer cannot call this function");
        _;
    }

    modifier noExistingMerchant(string calldata merchantName, string calldata merchantCity, string calldata countryCode, string calldata globalUniqueIdentifier, string calldata paymentNetworkSpecific) {
        require(!merchantAlreadyExists(merchantName, merchantCity, countryCode, globalUniqueIdentifier, paymentNetworkSpecific),"Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it.");
        _;
    }
    
    function isOwner(address owner) 
        public 
        view 
        returns (bool){
        for (uint index = 0; index < owners.length; index++) {
            if (owners[index] == owner) {
                return true;
            }
        }
        return false;
    }

    function getOwner() 
        public 
        view 
        returns (address[] memory) {
        return owners;
    }

    function addOwner(address newOwner) 
        public 
        onlyOwner {
        owners.push(newOwner);
    }

    function removeOwner(address oldOwner) 
        public 
        onlyOwner {
        //require oldOwner to be in owners array
        require(isOwner(oldOwner),"Error: Not an owner");
        require(owners.length > 1,"Error: Cannot remove last owner");

        //remove oldOwner from owners array
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == oldOwner) {
                delete owners[i];
                break;
            }
        }
    }
    function isAcquirer(address acquirer) 
        public 
        view 
        returns (bool){
        for (uint index = 0; index < acquirers.length; index++) {
            if (acquirers[index] == acquirer) {
                return true;
            }
        }
        return false;
    }
    function addAcquirer(address newAcquirer) 
        public 
        onlyOwner {
        acquirers.push(newAcquirer);
    }
    function getAcquirers() 
        public 
        view 
        returns (address[] memory) {
        return acquirers;
    }
    function removeAcquirer(address oldAcquirer) 
        public 
        onlyOwner {
        //require oldAcquirer to be in acquirers array
        require(isAcquirer(oldAcquirer),"Error: Not an acquirer");
        require(acquirers.length > 0,"Error: There are no acquirers");

        //remove oldAcquirer from acquirers array
        for (uint i = 0; i < acquirers.length; i++) {
            if (acquirers[i] == oldAcquirer) {
                delete acquirers[i];
                break;
            }
        }
    }

    function key(string calldata merchantName, string calldata merchantCity, string calldata countryCode, string calldata globalUniqueIdentifier, string calldata paymentNetworkSpecific) 
        internal 
        pure 
        returns (bytes32) {
        return keccak256(abi.encodePacked(merchantName, ",", merchantCity, ",", countryCode, ",", globalUniqueIdentifier, ",", paymentNetworkSpecific));
    }

    function registerQR(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific, address merchantAddress) 
        public 
        onlyAcquirer 
        noExistingMerchant(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific){
        lookup[msg.sender][key(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific)] = merchantAddress;
    }

    function deleteQR(string calldata merchantName, string calldata merchantCity, string calldata countryCode, string calldata globalUniqueIdentifier, string calldata paymentNetworkSpecific) 
        public 
        onlyAcquirer {
        delete lookup[msg.sender][key(merchantName, merchantCity, countryCode, globalUniqueIdentifier, paymentNetworkSpecific)];
    }

    function merchantAlreadyExists(string calldata merchantName, string calldata merchantCity, string calldata countryCode, string calldata globalUniqueIdentifier, string calldata paymentNetworkSpecific) 
        public 
        view 
        returns (bool) {
        return lookup[msg.sender][key(merchantName, merchantCity, countryCode, globalUniqueIdentifier, paymentNetworkSpecific)] != address(0);
    }

    function getMerchantAddress(string calldata merchantName, string calldata merchantCity, string calldata countryCode, string calldata globalUniqueIdentifier, string calldata paymentNetworkSpecific) 
        public 
        view 
        returns (address){
        return lookup[msg.sender][key(merchantName, merchantCity, countryCode, globalUniqueIdentifier, paymentNetworkSpecific)];
    }

}