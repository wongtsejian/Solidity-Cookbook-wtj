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
    event AcquirerAdded(address indexed acquirer, string organisationName);
    event AcquirerRemoved(address indexed acquirer, string organisationName);
    event MerchantRegistered(string indexed organisationName, string hashOfQRDestInfo, address indexed merchantAddress);
    event MerchantDeleted(string indexed organisationName, string hashOfQRDestInfo, address indexed merchantAddress);
    event OrganisationAdded(string indexed organisationName);
    event OrganisationRemoved(string indexed organisationName);

    // State variables
    // array of owners' addresses
    address[] private _owners;
    // array of whitelisted acquirers' addresses
    address[] private _acquirers;
    // array of whitelisted acquirers' organisation names
    string[] private _organisationNames;
    // _lookup mapping maps address of acquirer to a mapping of a hash of the QR_dest_info to the address of the merchant
    mapping (string => mapping(string => address)) private _lookup;
    // _organisation mapping maps address of an acquirer to the name of the organisation acquirer belongs to
    mapping (address => string) private _organisation;
    
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
    modifier notExistingMerchant(address _from, string calldata _hashOfQRDestInfo) {
        require(!_merchantAlreadyExists(_from, _hashOfQRDestInfo),"Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it.");
        _;
    }
    
    // @dev Checks if a merchant address is already registered with a particular acquirer
    modifier isExistingMerchant(address _from, string calldata _hashOfQRDestInfo) {
        require(_merchantAlreadyExists(_from, _hashOfQRDestInfo),"Error: Merchant does not exist.");
        _;
    }

    // @dev Checks if an organisation name is already registered
    modifier isExistingOrganisation(string calldata _organisationName) {
        require(organisationExists(_organisationName),"Error: Organisation does not exist.");
        _;
    }

    // @dev Checks if an organisation name is not already registered
    modifier notExistingOrganisation(string calldata _organisationName) {
        require(!organisationExists(_organisationName),"Error: Organisation already exists.");
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

    // @dev Adds an organisation to the list of organisation names
    // @param _organisationName The name of the organisation to be added
    function addOrganisationName(string calldata _organisationName) 
        public 
        onlyOwner 
        notExistingOrganisation(_organisationName){
        _organisationNames.push(_organisationName);
        emit OrganisationAdded(_organisationName);
    }

    // @dev Remove an organisation from list of organisation names
    // @param _organisationName The name of the organisation to be removed
    function removeOrganisationName(string calldata _organisationName) 
        public 
        onlyOwner 
        isExistingOrganisation(_organisationName){
        //require organisationName to be in organisationNames array
        require(_organisationNames.length > 0,"Error: There are no existing organisation names.");

        //remove organisationName from organisationNames array
        for (uint i = 0; i < _organisationNames.length; i++) {
            if (keccak256(abi.encodePacked(_organisationNames[i])) == keccak256(abi.encodePacked(_organisationName))) {
                delete _organisationNames[i];
                emit OrganisationRemoved(_organisationName);
                break;
            }
        }
    }

    function organisationExists(string calldata _organisationName) 
        public 
        view 
        returns (bool){
        for (uint index = 0; index < _organisationNames.length; index++) {
            if (keccak256(abi.encodePacked(_organisationNames[index])) == keccak256(abi.encodePacked(_organisationName))) {
                return true;
            }
        }
        return false;
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
    
    // @dev Adds an acquirer address to the _acquirers array and associates an organisation name to the acquirer
    // @param _newAcquirer The address of the acquirer to be added
    function addAcquirer(address _newAcquirer, string calldata _organisationName) 
        public 
        onlyOwner 
        isExistingOrganisation(_organisationName){
        _organisation[_newAcquirer] = _organisationName;
        _acquirers.push(_newAcquirer);
        emit AcquirerAdded(_newAcquirer, _organisationName);
    }

    // @dev Gets the list of whitelisted acquirers
    function getAcquirers() 
        public 
        view 
        returns (address[] memory) {
        return _acquirers;
    }

    // @dev Removes an acquirer address from the _acquirers array and removes the association of the organisation name to the acquirer
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
                string memory _organisationName = _organisation[_oldAcquirer];
                delete _organisation[_oldAcquirer];
                delete _acquirers[i];
                emit AcquirerRemoved(_oldAcquirer, _organisationName);
                break;
            }
        }
    }

    // @dev Registers a merchant address to a hash of the QR_dest_info and organisation name
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    // @param _merchantAddress The address of the merchant to be registered
    function registerQR(string calldata _hashOfQRDestInfo, address _merchantAddress) 
        public 
        onlyAcquirer 
        notExistingMerchant(msg.sender, _hashOfQRDestInfo){
        _lookup[_organisation[msg.sender]][_hashOfQRDestInfo] = _merchantAddress;
        emit MerchantRegistered(_organisation[msg.sender], _hashOfQRDestInfo, _merchantAddress);
    }

    // @dev Deletes a merchant address from the _lookup mapping
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function deleteQR(string calldata _hashOfQRDestInfo) 
        public 
        onlyAcquirer 
        isExistingMerchant(msg.sender, _hashOfQRDestInfo){
        address _merchantAddress = _lookup[_organisation[msg.sender]][_hashOfQRDestInfo];
        delete _lookup[_organisation[msg.sender]][_hashOfQRDestInfo];
        emit MerchantDeleted(_organisation[msg.sender], _hashOfQRDestInfo, _merchantAddress);
    }

    // @dev Checks if a hash of the QR_dest_info is already registered with an acquirer
    // @param from The address of the acquirer
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function _merchantAlreadyExists(address from, string calldata _hashOfQRDestInfo) 
        internal 
        view 
        returns (bool) {
        return _lookup[_organisation[from]][_hashOfQRDestInfo] != address(0);
    }

    // @dev Gets the merchant address when provided with a hash of the QR_dest_info.
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function getMerchantAddress(string calldata _hashOfQRDestInfo) 
        public 
        view 
        returns (address[] memory){
        address[] memory _merchantAddresses = new address[](1);
        
        for (uint i = 0; i<_organisationNames.length; i++) {
            if (_lookup[_organisationNames[i]][_hashOfQRDestInfo] != address(0)) {
                if (_merchantAddresses[0] == address(0)) {
                    _merchantAddresses[0] = _lookup[_organisationNames[i]][_hashOfQRDestInfo];
                } else {
                    _merchantAddresses = _pushAddress(_merchantAddresses,_lookup[_organisationNames[i]][_hashOfQRDestInfo]);
                }
            }
        }
        return _merchantAddresses;
    }
    
    //Utility functions
    // @dev Pushes a new address to an array of addresses
    function _pushAddress(address[] memory array, address newAddress) 
        internal
        pure 
        returns (address[] memory) {
        address[] memory newArray = new address[](array.length + 1);

        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = newAddress;
        return newArray;
    }

}