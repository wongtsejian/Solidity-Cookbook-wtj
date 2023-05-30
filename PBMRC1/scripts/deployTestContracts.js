// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const MultiSigWallet = await hre.ethers.getContractFactory("MultiSigWallet");
  const msg = await MultiSigWallet.deploy(["0xb9FdA735e6572C26CEF89f68E95B0423d8950985","0xa5fb83CEb5252187ADE7c928d08A5fc215Ec4226","0x683C816C6C6CaC1B3c850fc55061C47838C8E041"],2);
  const abi = MultiSigWallet.interface.format('json');
  console.log(MultiSigWallet);
  console.log(abi);
  console.log(
    `MultiSignatureWallet has been deployed to ${msg.address}. The return object: ${msg}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
