var Web3 = require('web3');
const jQuery = require('jquery');
const hre = require("hardhat");
var Contract = require('web3-eth-contract');
const CONTRACT_ADDRESS = "0x683daa166214f46973B15783bc0964f2510AFB90";
// Import the secrets file
const secrets = require("../secrets");
const hardhat1Address = "0xb9FdA735e6572C26CEF89f68E95B0423d8950985";
const hardhat1AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[0];
const hardhat2Address = "0xa5fb83CEb5252187ADE7c928d08A5fc215Ec4226";
const hardhat2AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[1];
const hardhat3Address = "0x683C816C6C6CaC1B3c850fc55061C47838C8E041";
const hardhat3AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[2];
const hardhat4Address = "0x8a832b32C2158C6Ff118b0D019f8697bfB6B5Ed4";
const hardhat4AddressPrivateKey= secrets.METAMASK_PRIVATE_KEYS[3];

async function getJSONInterface() {
    const MultiSigWallet = await hre.ethers.getContractAt("MultiSignatureWallet", CONTRACT_ADDRESS);
    const jsonInterface = MultiSigWallet.interface.format('json');
    console.log(jsonInterface);
    return jsonInterface;
}
const jsonInterface = getJSONInterface();
/** 
const jsonInterface = [{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"owners","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"transactionId","type":"uint256"}],"name":"revokeConfirmation","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"isOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"address"}],"name":"confirmations","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"transactions","outputs":[{"name":"executed","type":"bool"},{"name":"destination","type":"address"},{"name":"value","type":"uint256"},{"name":"data","type":"bytes"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"transactionCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"transactionId","type":"uint256"}],"name":"confirmTransaction","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"destination","type":"address"},{"name":"value","type":"uint256"},{"name":"data","type":"bytes"}],"name":"submitTransaction","outputs":[{"name":"transactionId","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"required","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"transactionId","type":"uint256"}],"name":"executeTransaction","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_owners","type":"address[]"},{"name":"_required","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"sender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"transactionId","type":"uint256"}],"name":"Submission","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"transactionId","type":"uint256"}],"name":"Confirmation","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"transactionId","type":"uint256"}],"name":"Execution","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"transactionId","type":"uint256"}],"name":"ExecutionFailure","type":"event"}]

var contract = new Contract(jsonInterface , CONTRACT_ADDRESS);

const web3 = new Web3(`https://polygon-mumbai.g.alchemy.com/v2/${secrets.MUMBAI_API_KEY}`);
// set provider for all later instances to use
const provider = "https://polygon-mumbai.g.alchemy.com/v2/"+secrets.MUMBAI_API_KEY
contract.setProvider(provider);

//Set defaults

contract.defaultChain = "mumbai";

contract.defaultAccount = hardhat1Address;

//retrieve transaction count
const transactionCount = contract.methods.transactionCount()
.call()
.then((result) => console.log("Transaction Counts: ", result))
.catch((error) => {
    console.error('Error:', error);
  });
/**
//retrieve confirmations for transactions
const confirmations = contract.methods.confirmations(1,hardhat1Address)
.call()
.then((result) => console.log(`Has ${hardhat1Address} confirmed: `, result))
.catch((error) => {
    console.error('Error:', error);
  });



const { Alchemy, Network, Wallet, Utils } = require("alchemy-sdk");

const settings = {
  apiKey: secrets.MUMBAI_API_KEY,
  network: Network.MATIC_MUMBAI,
};
const alchemy = new Alchemy(settings);
let wallet1 = new Wallet(secrets.METAMASK_PRIVATE_KEYS[0]);
let wallet2 = new Wallet(secrets.METAMASK_PRIVATE_KEYS[1]);
let wallet3 = new Wallet(secrets.METAMASK_PRIVATE_KEYS[2]);
let wallet4 = new Wallet(secrets.METAMASK_PRIVATE_KEYS[3]);

//submit transaction
async function submitTransaction() {
    const nonce = await alchemy.core.getTransactionCount(
        wallet1.address,
        "latest"
    );

    const data = contract.methods.submitTransaction(hardhat4Address, 789, "0x").encodeABI();
    const transaction = {
        from: hardhat1Address,
        to: CONTRACT_ADDRESS,
        data: data,
        gasLimit: "210000",
        maxPriorityFeePerGas: Utils.parseUnits("5", "gwei"),
        maxFeePerGas: Utils.parseUnits("100", "gwei"),
        nonce: nonce,
        type: 2,
        chainId: 80001,
    };
    let rawTransaction = await wallet1.signTransaction(transaction);
    let tx = await alchemy.core.sendTransaction(rawTransaction);
    console.log("Sent transaction", tx);
}
//submitTransaction();


//confirm transaction

async function confirmTransaction() {
    const nonce = await alchemy.core.getTransactionCount(
        wallet3.address,
        "latest"
    );
    const data = contract.methods.confirmTransaction(2).encodeABI();
    const transaction = {
        from: hardhat3Address,
        to: CONTRACT_ADDRESS,
        data: data,
        gasLimit: "210000",
        maxPriorityFeePerGas: Utils.parseUnits("5", "gwei"),
        maxFeePerGas: Utils.parseUnits("100", "gwei"),
        nonce: nonce,
        type: 2,
        chainId: 80001,
    };
    let rawTransaction = await wallet3.signTransaction(transaction);
    let tx = await alchemy.core.sendTransaction(rawTransaction);
    console.log("Sent transaction", tx);
}
confirmTransaction();
*/