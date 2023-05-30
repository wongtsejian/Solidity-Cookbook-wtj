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

    while(!hasSelectedFn){
        // Get user input on which function to call. User can call replaceOwner, addOwner, removeOwner, confirmTransaction, revokeConfirmation and changeRequirement.
        const fnToCall = readlineSync.question("Enter the corresponding number to select transaction to generate: /n1. replaceOwner/n2. addOwner/n3. removeOwner/n4. confirmTransaction/n5. revokeConfirmation/n6. changeRequirement");
        console.log('Function selected:', fnToCall);
        var data = null;
        switch(fnToCall){
            case "1":
                data = replaceOwner(contract);
                hasSelectedFn = true;
                break;
            case "2":
                data = addOwner(contract);
                hasSelectedFn = true;
                break;
            case "3":
                data = removeOwner(contract);
                hasSelectedFn = true;
                break;
            case "4":
                data = confirmTransaction(contract);
                hasSelectedFn = true;
                break;
            case "5":
                data = revokeConfirmation(contract);
                hasSelectedFn = true;
                break;
            case "6":
                data = changeRequirement(contract);
                hasSelectedFn = true;
                break;
            default:
                console.log("Invalid input. Please try again.");
        }
    }

    // Create an unsigned replaceOwner transaction object
    //const replaceOwnerUnsignedMsg = await contract.populateTransaction.submitTransaction(CONTRACT_ADDRESS,0,replaceOwnerData);
    //console.log(replaceOwnerUnsignedMsg);
    const unsignedTx = generateUnsignedSubmitTx(data);

    // Save transaction as JSON file
    const txJson = JSON.stringify(unsignedTx);
    console.log(txJson);
    fs.writeFileSync('tx.json', txJson);


    // Sign transaction object offline using ethers.js
    const wallet1 = new ethers.Wallet(secrets.METAMASK_PRIVATE_KEYS[0], provider);
    const signedTransaction1a = await wallet1.populateTransaction(replaceOwnerUnsignedMsg);
    const signedTransaction1b = await wallet1.signTransaction(signedTransaction1a);
    console.log(signedTransaction1b);

    // Send the signed transaction object to the network
    const tx = await provider.sendTransaction(signedTransaction1b);
    console.log(tx);

    /**
    // Create an unsigned confirmTransaction transaction object
    const confirmTransactionUnsignedMsg = await contract.populateTransaction.confirmTransaction(0,overrides);
    console.log(confirmTransactionUnsignedMsg);

    // Save transaction as JSON file
    const txJson2 = JSON.stringify(confirmTransactionUnsignedMsg);
    console.log(txJson2);
    fs.writeFileSync('tx2.json', txJson2);

    // Sign transaction object offline using ethers.js
    const wallet2 = new ethers.Wallet(secrets.METAMASK_PRIVATE_KEYS[1], provider);
    const signedTransaction2 = await wallet2.signTransaction(confirmTransactionUnsignedMsg);
    console.log(signedTransaction2);
    */
}

async function generateUnsignedSubmitTx(data) {
    // Create an unsigned replaceOwner transaction object
    const unsignedTx = await contract.populateTransaction.submitTransaction(CONTRACT_ADDRESS,0,data);
    console.log(unsignedTx);
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

async function confirmTransaction(contract){
    // Get user input for transaction ID to confirm
    const transactionId = readlineSync.question("Enter the transaction ID: ");
    console.log('Transaction ID:', transactionId);

    //Encode the function call
    const confirmTransactionData = contract.interface.encodeFunctionData('confirmTransaction', [transactionId]);

    return confirmTransactionData;
}

async function revokeConfirmation(contract){
    // Get user input for transaction ID to revoke
    const transactionId = readlineSync.question("Enter the transaction ID: ");
    console.log('Transaction ID:', transactionId);

    //Encode the function call
    const revokeConfirmationData = contract.interface.encodeFunctionData('revokeConfirmation', [transactionId]);

    return revokeConfirmationData;
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
  