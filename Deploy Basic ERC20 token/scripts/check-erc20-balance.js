const hre = require("hardhat");
const fs = require("fs")
const path = require("path")

const getTheAbi = () => {
  try {
    const dir = path.resolve(
      __dirname,
      "../artifacts/contracts/VictorXSGD.sol/VictorXSGD.json"
    )
    const file = fs.readFileSync(dir, "utf8")
    const json = JSON.parse(file)
    const abi = json.abi
    // console.log(`abi`, abi)

    return abi
  } catch (e) {
    console.log(`e`, e)
  }
}

async function deploy() {
  var ethers = hre.ethers;
  const ContractFactory = await ethers.getContractFactory("VictorXSGD");

  const instance = await ContractFactory.deploy();
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}


async function main() {

  await deploy();
  const [signer] = await hre.ethers.getSigners();
  const signerAddress = await signer.getAddress();
  console.log(`Signer Address: ${signerAddress}`);
  const tokenContractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  // replace with your values
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const abi = [
    // Add your contract's ABI here
    "function balanceOf(address owner) view returns (uint256)",
    // "function haha(address owner) view returns (uint256)",
    "function haha() pure public returns (uint256)",
    // Add more functions as needed
  ];
  console.log("!!!!!!!!!!!!!!!!!");
  console.log(await hre.ethers.provider.getCode(tokenContractAddress));

  const contract = await hre.ethers.getContractAt(abi, contractAddress, signer);
  const haha = await contract.haha();
  console.log(`haha: ${haha}} `);

  // Now you can call functions on the contract
  const balance = await contract.balanceOf(signer.address);
  console.log(`Balance: ${hre.ethers.utils.formatUnits(balance, 18)} Tokens`);
//-----------------------------------




//   const ERC20ABI = ["function balanceOf(address account) external view returns (uint256)"];
  const ERC20ABI = getTheAbi();
  const token = await hre.ethers.getContractAt(ERC20ABI, tokenContractAddress, signer);
  tokenBalance = await token.balanceOf(signerAddress);

  console.log(`Balance: ${ethers.utils.formatUnits(tokenBalance, 18)} Tokens`);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
