/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2023 Xfers Pte. Ltd.
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
    event AcquirerAdded(address indexed acquirer, string organisationName);
    event AcquirerRemoved(address indexed acquirer, string organisationName);
    event MerchantRegistered(string indexed organisationName, string hashOfQRDestInfo, address indexed merchantAddress);
    event MerchantDeregistered(string indexed organisationName, string hashOfQRDestInfo, address indexed merchantAddress);
    event OrganisationAdded(string indexed organisationName);
    event OrganisationRemoved(string indexed organisationName);

    // State variables
    // array of owners' addresses
    address private _owner;
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
        _owner = msg.sender;
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
    modifier notRegisteredMerchant(address _from, string calldata _hashOfQRDestInfo) {
        require(!_merchantAlreadyRegistered(_from, _hashOfQRDestInfo),"Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it.");
        _;
    }
    
    // @dev Checks if a merchant address is already registered with a particular acquirer
    modifier registeredMerchant(address _from, string calldata _hashOfQRDestInfo) {
        require(_merchantAlreadyRegistered(_from, _hashOfQRDestInfo),"Error: Merchant does not exist.");
        _;
    }

    // @dev Checks if an organisation name is already registered
    modifier registeredOrganisation(string calldata _organisationName) {
        require(organisationAlreadyRegistered(_organisationName),"Error: Organisation does not exist.");
        _;
    }

    // @dev Checks if an organisation name is not already registered
    modifier notRegisteredOrganisation(string calldata _organisationName) {
        require(!organisationAlreadyRegistered(_organisationName),"Error: Organisation already exists.");
        _;
    }

    // @dev Checks if an address is the owner
    // @param _owner The address to be checked
    // @return True if the address is the owner, false otherwise
    function isOwner(address _from) 
        public 
        view 
        returns (bool){
        return _from == _owner;
    }

    // @dev Gets the owner's address
    // @return The owner's address
    function getOwner() 
        public 
        view 
        returns (address) {
        return _owner;
    }

    // @dev Adds an organisation to the list of organisation names
    // @param _organisationName The name of the organisation to be added
    function addOrganisation(string calldata _organisationName) 
        public 
        onlyOwner 
        notRegisteredOrganisation(_organisationName){
        _organisationNames.push(_organisationName);
        emit OrganisationAdded(_organisationName);
    }

    // @dev Remove an organisation from list of organisation names
    // @param _organisationName The name of the organisation to be removed
    function removeOrganisation(string calldata _organisationName) 
        public 
        onlyOwner 
        registeredOrganisation(_organisationName){
        //require organisationName to be in organisationNames array
        require(_organisationNames.length > 0,"Error: There are no existing organisation names.");
        
        // remove all acquirers associated with the organisation to ensure these acquirers are no longer able to register and deregister merchants. There's no need to remove merchant addresses as getMerchantAddress() will check that the hash is associated to a registered organisation name before returning merchant address.
        for (uint i = 0; i < _acquirers.length; i++) {
            if (keccak256(abi.encodePacked(_organisation[_acquirers[i]])) == keccak256(abi.encodePacked(_organisationName))) {
                delete _organisation[_acquirers[i]];
                delete _acquirers[i];
                emit AcquirerRemoved(_acquirers[i], _organisationName);
            }
        }

        // remove organisationName from organisationNames array
        for (uint i = 0; i < _organisationNames.length; i++) {
            if (keccak256(abi.encodePacked(_organisationNames[i])) == keccak256(abi.encodePacked(_organisationName))) {
                delete _organisationNames[i];
                break;
            }
        }
        emit OrganisationRemoved(_organisationName);
    }

    // @dev Checks if an organisation name is already registered
    // @param _organisationName The name of the organisation to be checked
    // @return True if the organisation name is already registered, false otherwise
    function organisationAlreadyRegistered(string calldata _organisationName) 
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
    // @return True if the address is an acquirer, false otherwise
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
        registeredOrganisation(_organisationName){
        require(!isAcquirer(_newAcquirer),"Error: Acquirer already exists.");
        _organisation[_newAcquirer] = _organisationName;
        _acquirers.push(_newAcquirer);
        emit AcquirerAdded(_newAcquirer, _organisationName);
    }

    // @dev Gets the list of whitelisted acquirers
    // @return The list of whitelisted acquirers
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
    function registerMerchantQR(string calldata _hashOfQRDestInfo, address _merchantAddress) 
        public 
        onlyAcquirer 
        notRegisteredMerchant(msg.sender, _hashOfQRDestInfo){
        _lookup[_organisation[msg.sender]][_hashOfQRDestInfo] = _merchantAddress;
        emit MerchantRegistered(_organisation[msg.sender], _hashOfQRDestInfo, _merchantAddress);
    }

    // @dev Deletes a merchant address from the _lookup mapping
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    function deregisterMerchantQR(string calldata _hashOfQRDestInfo) 
        public 
        onlyAcquirer 
        registeredMerchant(msg.sender, _hashOfQRDestInfo){
        address _merchantAddress = _lookup[_organisation[msg.sender]][_hashOfQRDestInfo];
        delete _lookup[_organisation[msg.sender]][_hashOfQRDestInfo];
        emit MerchantDeregistered(_organisation[msg.sender], _hashOfQRDestInfo, _merchantAddress);
    }

    // @dev Checks if a hash of the QR_dest_info is already registered with an acquirer
    // @param from The address of the acquirer
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    // @return True if the hash of the QR_dest_info is already registered with an acquirer, false otherwise
    function _merchantAlreadyRegistered(address from, string calldata _hashOfQRDestInfo) 
        internal 
        view 
        returns (bool) {
        return _lookup[_organisation[from]][_hashOfQRDestInfo] != address(0);
    }

    // @dev Gets the merchant address when provided with a hash of the QR_dest_info. Alternatively, an offline database can be build using the events emitted to enable gas free search.
    // @param _hashOfQRDestInfo The Keccak256 hash of the QR_dest_info
    // @return The address of the merchant. If the merchant address is not found, reverts that merchant is not registered.
    function getMerchantAddress(string calldata _hashOfQRDestInfo) 
        public 
        view 
        returns (address){
        // Search through all organisation names to find the merchant address
        for (uint i = 0; i<_organisationNames.length; i++) {
            if (_lookup[_organisationNames[i]][_hashOfQRDestInfo] != address(0)) {
                return _lookup[_organisationNames[i]][_hashOfQRDestInfo];
            }
        }
        revert("Error: Merchant is not registered.");
    }

}