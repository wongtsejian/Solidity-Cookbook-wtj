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
    
    // Events
    event OwnerAdded(address indexed owner);
    event OwnerRemoved(address indexed owner);
    event AcquirerAdded(address indexed acquirer);
    event AcquirerRemoved(address indexed acquirer);
    event MerchantRegistered(address indexed acquirer, string hashOfQRDestInfo, address indexed merchantAddress);
    event MerchantDeleted(address indexed acquirer, string hashOfQRDestInfo);

    // State variables
    address[] private _owners;
    address[] private _acquirers;
    //mapping maps address of acquirer to a mapping of a hash of the QR_dest_info to the address of the merchant
    mapping (address => mapping(string => address)) private _lookup;
    
    // @dev Fallback function
    fallback() external payable {
        revert("Error: Fallback function not allowed.");
    }

    // @dev Receive function
    receive() external payable {
        revert("Error: Receive function not allowed.");
    }

    // @dev Constructor
    constructor() {
        _owners.push(msg.sender);
    }

    // @dev Checks if a caller is an owner
    modifier onlyOwner() {
        require(isOwner(msg.sender),"Error: Non-owners cannot call this function.");
        _;
    }

    // @dev Checks if a caller is an acquirer
    modifier onlyAcquirer() {
        require(isAcquirer(msg.sender),"Error: Non-acquirer cannot call this function.");
        _;
    }

    // @dev Checks if a merchant address is not already registered with a particular acquirer
    modifier notExistingMerchant(address from, string calldata _hashOfQRDestInfo) {
        require(!_merchantAlreadyExists(from, _hashOfQRDestInfo),"Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it.");
        _;
    }
    
    // @dev Checks if a merchant address is already registered with a particular acquirer
    modifier isExistingMerchant(address from, string calldata _hashOfQRDestInfo) {
        require(_merchantAlreadyExists(from, _hashOfQRDestInfo),"Error: Merchant does not exist.");
        _;
    }

    // @dev Checks if an address is an owner
    // @param _owner The address to be checked
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

    // @dev Gets the list of owners
    function getOwner() 
        public 
        view 
        returns (address[] memory) {
        return _owners;
    }

    // @dev Adds an owner address to the _owners array
    // @param _newOwner The address of the owner to be added
    function addOwner(address _newOwner) 
        public 
        onlyOwner {
        _owners.push(_newOwner);
        emit OwnerAdded(_newOwner);
    }

    // @dev Removes an owner address from the _owners array
    // @param _oldOwner The address of the owner to be removed
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
                emit OwnerRemoved(_oldOwner);
                break;
            }
        }
    }

    // @dev Checks if an address is an acquirer
    // @param _acquirer The address to be checked
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
    
    // @dev Adds an acquirer address to the _acquirers array
    // @param _newAcquirer The address of the acquirer to be added
    function addAcquirer(address _newAcquirer) 
        public 
        onlyOwner {
        _acquirers.push(_newAcquirer);
        emit AcquirerAdded(_newAcquirer);
    }

    // @dev Gets the list of acquirers
    function getAcquirers() 
        public 
        view 
        returns (address[] memory) {
        return _acquirers;
    }

    // @dev Removes an acquirer address from the _acquirers array
    // @param _oldAcquirer The address of the acquirer to be removed
    function removeAcquirer(address _oldAcquirer) 
        public 
        onlyOwner {
        //require oldAcquirer to be in acquirers array
        require(isAcquirer(_oldAcquirer),"Error: Not an acquirer.");
        require(_acquirers.length > 0,"Error: There are no existing acquirers.");

        //remove oldAcquirer from acquirers array
        for (uint i = 0; i < _acquirers.length; i++) {
            if (_acquirers[i] == _oldAcquirer) {
                delete _acquirers[i];
                emit AcquirerRemoved(_oldAcquirer);
                break;
            }
        }
    }

    // @dev Registers a merchant address to a hash of the QR_dest_info
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    // @param _merchantAddress The address of the merchant to be registered
    function registerQR(string calldata _hashOfQRDestInfo, address _merchantAddress) 
        public 
        onlyAcquirer 
        notExistingMerchant(msg.sender, _hashOfQRDestInfo){
        _lookup[msg.sender][_hashOfQRDestInfo] = _merchantAddress;
        emit MerchantRegistered(msg.sender, _hashOfQRDestInfo, _merchantAddress);
    }

    // @dev Deletes a merchant address the _lookup mapping
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function deleteQR(string calldata _hashOfQRDestInfo) 
        public 
        onlyAcquirer 
        isExistingMerchant(msg.sender, _hashOfQRDestInfo){
        delete _lookup[msg.sender][_hashOfQRDestInfo];
        emit MerchantDeleted(msg.sender, _hashOfQRDestInfo);
    }

    // @dev Checks if a hash of the QR_dest_info is already registered with an acquirer
    // @param from The address of the acquirer
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function _merchantAlreadyExists(address from, string calldata _hashOfQRDestInfo) 
        internal 
        view 
        returns (bool) {
        return _lookup[from][_hashOfQRDestInfo] != address(0);
    }

    // @dev Gets the merchant address of a hash of the QR_dest_info
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function getMerchantAddress(string calldata _hashOfQRDestInfo) 
        public 
        view 
        returns (address){
        return _lookup[msg.sender][_hashOfQRDestInfo];
    }

}