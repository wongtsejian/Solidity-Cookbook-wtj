// Import the secrets file
const secrets = require("../secrets");

const a = require('alchemy-sdk');

const settings = {
    apiKey: secrets.MUMBAI_API_KEY,
    network: a.Network.MATIC_MUMBAI,
};

const alchemy = new a.Alchemy(settings);

// get the latest block
const latestBlock = alchemy.core.getBlock("latest").then(console.log);