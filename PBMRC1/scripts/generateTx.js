// This script generates a transaction to be signed by the multisig wallet

const hre = require("hardhat");
var Contract = require('web3-eth-contract');
const readlineSync = require('readline-sync');
const fs = require('fs');
const CONTRACT_ADDRESS = "0xfD3cE77164Bbe16b91D2dfF104CB8114Fe6e58Fc";
// Import the secrets file
const secrets = require("../secrets");
/** 
const hardhat1Address = "0xb9FdA735e6572C26CEF89f68E95B0423d8950985";
const hardhat1AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[0];
const hardhat2Address = "0xa5fb83CEb5252187ADE7c928d08A5fc215Ec4226";
const hardhat2AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[1];
const hardhat3Address = "0x683C816C6C6CaC1B3c850fc55061C47838C8E041";
const hardhat3AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[2];
const hardhat4Address = "0x8a832b32C2158C6Ff118b0D019f8697bfB6B5Ed4";
const hardhat4AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[3];
*/
async function main() {
   
    /**
    //Get user input for replaced owner address
    const replacedOwnerAddress = readlineSync.question("Enter the address to be replaced: ");
    console.log('Owner to be replaced:', replacedOwnerAddress);
    // Get user input for new owner address
    const newOwnerAddress = readlineSync.question("Enter the address to be added as an owner: ");
    console.log('Owner to be added:', newOwnerAddress);
     */
    // Set Alchemy as Mumbai Polygon testnet provider
    const provider = new ethers.providers.JsonRpcProvider(`https://polygon-mumbai.g.alchemy.com/v2/${secrets.MUMBAI_API_KEY}`);
    // Get the contract ABI
    const contractArtifact = await artifacts.readArtifact("MultiSigWallet");
    const contractAbi = contractArtifact.abi;
    // Create a new contract instance with the contract ABI and contract address
    const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, provider);
    // Create an unsigned transaction object
    const overrides = {
        gasLimit: 300000,
        gasPrice: 33000000000,
        value: 0,
    }
    var hasSelectedFn = false;
    var needSubmitTx = true;
    var data = null;
    var unsignedTx = null;
    var selectedFn = null;
    while(!hasSelectedFn){
        // Get user input on which function to call. User can call replaceOwner, addOwner, removeOwner, confirmTransaction, revokeConfirmation and changeRequirement.
        const fnToCall = readlineSync.question("Enter the corresponding number to select transaction to generate: \n1. replaceOwner\n2. addOwner\n3. removeOwner\n4. confirmTransaction\n5. revokeConfirmation\n6. changeRequirement\nSelected Function:");
        console.log('Function selected:', fnToCall);
        switch(fnToCall){
            // As only the multi-signature wallet can call replaceOwner, addOwner, removeOwner, and changeRequirement, the function calls are wrapped in a submitTransaction function call to allow the multi-signature wallet to call them once sufficient confirmations are met
            // As confirmTransaction and revokeConfirmation are signed individually, the function calls are not wrapped in a submitTransaction function call
            case "1":
                data = replaceOwner(contract);
                hasSelectedFn = true;
                selectedFn = "replaceOwner";
                break;
            case "2":
                data = addOwner(contract);
                hasSelectedFn = true;
                selectedFn = "addOwner";
                break;
            case "3":
                data = removeOwner(contract);
                hasSelectedFn = true;
                selectedFn = "removeOwner";
                break;
            case "4":
                unsignedTx = await confirmTransaction(contract,overrides);
                console.log("UnsignedTx:",unsignedTx);
                hasSelectedFn = true;
                selectedFn = "confirmTransaction";
                needSubmitTx = false;
                break;
            case "5":
                unsignedTx = await revokeConfirmation(contract,overrides);
                console.log("UnsignedTx:",unsignedTx);
                hasSelectedFn = true;
                selectedFn = "revokeConfirmation";
                needSubmitTx = false;
                break;
            case "6":
                data = changeRequirement(contract);
                hasSelectedFn = true;
                selectedFn = "changeRequirement";
                break;
            default:
                console.log("Invalid input. Please try again.\n");
        }
    }

    // Create an unsigned replaceOwner transaction object
    //const replaceOwnerUnsignedMsg = await contract.populateTransaction.submitTransaction(CONTRACT_ADDRESS,0,replaceOwnerData);
    //console.log(replaceOwnerUnsignedMsg);
    
    if (needSubmitTx){
        unsignedTx = await generateUnsignedSubmitTx(contract,data,overrides);
        console.log("UnsignedTx:",unsignedTx);
    } 

    // Save transaction as JSON file
    const txJson = JSON.stringify(unsignedTx);
    console.log("TxJson",txJson);
    
    // Import the filenameGenerator file
    const generateFilename = require('./utils');
    // Generate a filename for the transaction
    const filename = generateFilename(selectedFn);

    fs.writeFileSync(filename, txJson);

    /** Send the signed transaction object to the network for testing to confirm the item works
    // Sign transaction object offline using ethers.js
    //Get user input for which wallet to sign the transaction
    const walletToSign = readlineSync.question("Enter the corresponding number to select wallet to sign the transaction: \n1. hardhat1\n2. hardhat2\n3. hardhat3\n4. hardhat4\nSelected Wallet:");
    console.log('Wallet selected:', walletToSign);
    const wallet = new ethers.Wallet(secrets.METAMASK_PRIVATE_KEYS[walletToSign-1], provider);

    const signedTransaction1a = await wallet.populateTransaction(unsignedTx);
    const signedTransaction1b = await wallet.signTransaction(signedTransaction1a);
    console.log(signedTransaction1b);

    // Send the signed transaction object to the network
    const tx = await provider.sendTransaction(signedTransaction1b);
    console.log("Sent Tx:",tx);
    */
}
// Send signed transaction object to the network
async function sendSignedTx(signedTransaction,provider){
    const tx = await provider.sendTransaction(signedTransaction);
    console.log("Sent Tx:",tx);
}

async function generateUnsignedSubmitTx(contract,data,overrides) {
    // Create an unsigned replaceOwner transaction object
    const unsignedTx = await contract.populateTransaction.submitTransaction(CONTRACT_ADDRESS,0,data,overrides);
    console.log("UnsignedTx:",unsignedTx);
    return unsignedTx;
}

async function replaceOwner(contract){
    //Get user input for replaced owner address
    const replacedOwnerAddress = readlineSync.question("Enter the address to be replaced: ");
    console.log('Owner to be replaced:', replacedOwnerAddress);
    // Get user input for new owner address
    const newOwnerAddress = readlineSync.question("Enter the address to be added as an owner: ");
    console.log('Owner to be added:', newOwnerAddress);
    
    // Encode the function call
    const replaceOwnerData = contract.interface.encodeFunctionData('replaceOwner', [replacedOwnerAddress, newOwnerAddress]);

    return replaceOwnerData;
}

async function addOwner(contract){
    // Get user input for new owner address
    const newOwnerAddress = readlineSync.question("Enter the address to be added as an owner: ");
    console.log('Owner to be added:', newOwnerAddress);

    //Encode the function call
    const addOwnerData = contract.interface.encodeFunctionData('addOwner', [newOwnerAddress]);

    return addOwnerData;
}

async function removeOwner(contract){
    // Get user input for existing owner address to be removed
    const existingOwnerAddress = readlineSync.question("Enter the address to be removed as an owner: ");
    console.log('Owner to be removed:', existingOwnerAddress);

    //Encode the function call
    const removeOwnerData = contract.interface.encodeFunctionData('removeOwner', [existingOwnerAddress]);

    return removeOwnerData;
}

async function confirmTransaction(contract,overrides){
    // Get user input for transaction ID to confirm
    const transactionId = readlineSync.question("Enter the transaction ID: ");
    console.log('Transaction ID:', transactionId);

    //Encode the function call
    const unsignedTx = await contract.populateTransaction.confirmTransaction(transactionId,overrides);

    return unsignedTx;
}

async function revokeConfirmation(contract,overrides){
    // Get user input for transaction ID to revoke
    const transactionId = readlineSync.question("Enter the transaction ID: ");
    console.log('Transaction ID:', transactionId);

    //Encode the function call
    const unsignedTx = await contract.populateTransaction.revokeConfirmation(transactionId,overrides);

    return unsignedTx;
}

async function changeRequirement(contract){
    // Get user input for new minimum number of required confirmations
    const newRequired = readlineSync.question("Enter the new minimum number of required confirmations (inclusive of owner who submitted the transaction): ");
    console.log('New minimum number of required confirmations:', newRequired);

    //Encode the function call
    const changeRequirementData = contract.interface.encodeFunctionData('changeRequirement', [newRequired]);

    return changeRequirementData;
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  