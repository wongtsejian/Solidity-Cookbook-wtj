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
    
    address[] private _owners;
    address[] private _acquirers;
    //mapping maps address of acquirer to a mapping of a hash of the QR_dest_info to the address of the merchant
    mapping (address => mapping(bytes32 => address)) private _lookup;
    
    constructor() {
        _owners.push(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender),"Error: Non-owners cannot call this function");
        _;
    }

    modifier onlyAcquirer() {
        require(isAcquirer(msg.sender),"Error: Non-acquirer cannot call this function");
        _;
    }

    modifier noExistingMerchant(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific) {
        require(!merchantAlreadyExists(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific),"Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it.");
        _;
    }
    
    function isOwner(address _owner) 
        public 
        view 
        returns (bool){
        for (uint index = 0; index < _owners.length; index++) {
            if (_owners[index] == _owner) {
                return true;
            }
        }
        return false;
    }

    function getOwner() 
        public 
        view 
        returns (address[] memory) {
        return _owners;
    }

    function addOwner(address _newOwner) 
        public 
        onlyOwner {
        _owners.push(_newOwner);
    }

    function removeOwner(address _oldOwner) 
        public 
        onlyOwner {
        //require oldOwner to be in owners array
        require(isOwner(_oldOwner),"Error: Not an owner");
        require(_owners.length > 1,"Error: Cannot remove last owner");

        //remove oldOwner from owners array
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == _oldOwner) {
                delete _owners[i];
                break;
            }
        }
    }
    function isAcquirer(address _acquirer) 
        public 
        view 
        returns (bool){
        for (uint index = 0; index < _acquirers.length; index++) {
            if (_acquirers[index] == _acquirer) {
                return true;
            }
        }
        return false;
    }
    function addAcquirer(address _newAcquirer) 
        public 
        onlyOwner {
        _acquirers.push(_newAcquirer);
    }
    function getAcquirers() 
        public 
        view 
        returns (address[] memory) {
        return _acquirers;
    }
    function removeAcquirer(address _oldAcquirer) 
        public 
        onlyOwner {
        //require oldAcquirer to be in acquirers array
        require(isAcquirer(_oldAcquirer),"Error: Not an acquirer");
        require(_acquirers.length > 0,"Error: There are no acquirers");

        //remove oldAcquirer from acquirers array
        for (uint i = 0; i < _acquirers.length; i++) {
            if (_acquirers[i] == _oldAcquirer) {
                delete _acquirers[i];
                break;
            }
        }
    }

    function _key(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific) 
        internal 
        pure 
        returns (bytes32) {
        return keccak256(abi.encodePacked(_merchantName, ",", _merchantCity, ",", _countryCode, ",", _globalUniqueIdentifier, ",", _paymentNetworkSpecific));
    }

    function registerQR(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific, address _merchantAddress) 
        public 
        onlyAcquirer 
        noExistingMerchant(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific){
        _lookup[msg.sender][_key(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific)] = _merchantAddress;
    }

    function deleteQR(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific) 
        public 
        onlyAcquirer {
        delete _lookup[msg.sender][_key(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific)];
    }

    function merchantAlreadyExists(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific) 
        public 
        view 
        returns (bool) {
        return _lookup[msg.sender][_key(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific)] != address(0);
    }

    function getMerchantAddress(string calldata _merchantName, string calldata _merchantCity, string calldata _countryCode, string calldata _globalUniqueIdentifier, string calldata _paymentNetworkSpecific) 
        public 
        view 
        returns (address){
        return _lookup[msg.sender][_key(_merchantName, _merchantCity, _countryCode, _globalUniqueIdentifier, _paymentNetworkSpecific)];
    }

}