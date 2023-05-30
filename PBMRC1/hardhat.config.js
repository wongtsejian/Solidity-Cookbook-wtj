// Import hardhat plugins
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");

// Import the secrets file
const secrets = require("./secrets");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
const INFURA_API_KEY = secrets.INFURA_API_KEY;

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const SEPOLIA_PRIVATE_KEY = secrets.METAMASK_PRIVATE_KEYS;
const MUMBAI_PRIVATE_KEY = secrets.METAMASK_PRIVATE_KEYS;
const ETHERSCAN_API_KEY = secrets.etherscanApiKey;
const POLYGON_API_KEY = secrets.polygonscanApiKey;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.18", // First compiler version
      },
      {
        version: "0.5.10", // Second compiler version
      },
      {
        version: "0.4.15", // Third compiler version
      },
    ],
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  polygonscan: {
    apiKey: POLYGON_API_KEY,
  },
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${secrets.INFURA_API_KEY}`,
      accounts: SEPOLIA_PRIVATE_KEY,
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${secrets.MUMBAI_API_KEY}`,
      accounts: MUMBAI_PRIVATE_KEY,
    },
  },
};


// task action function receives the Hardhat Runtime Environment as second argument
task("accounts", "Prints accounts", async (_, { web3 }) => {
  console.log(await web3.eth.getAccounts());
});

