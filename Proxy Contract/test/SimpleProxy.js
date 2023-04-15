const { expect } = require("chai");
const { ethers } = require("hardhat");

let proxy, logic;
async function deployContracts() {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    let Proxy = await ethers.getContractFactory("SimpleProxy");
    proxy = await Proxy.deploy();
    let Logic = await ethers.getContractFactory("ProxyImplementation");
    logic = await Logic.deploy();
}

describe("Proxy", async function () {
    before(async () => {
        await deployContracts();
    });

    it("Set logic", async () => {
        proxy.setImplementation(logic.address);
    });

    it("Proxy call", async () => {
        const Implementation = await ethers.getContractFactory("Logic");
        const proxyContract = await Implementation.attach(
            proxy.address // The deployed contract address
        );

        // sets storage vars in logic contract.
        await logic.setNumber(30); 
        console.log("Base: ", (await logic.getNumber()).toString());
        expect(await logic.getNumber()).to.eq(30);
    
        
        const myProxy = new ethers.Contract(
            proxy.address,       
            ["function setNumber(uint _number) external", 
            "function getNumber() external view returns(uint)"],
            owner
        );

        await myProxy.setNumber(100);
        console.log("My Proxy: ", (await myProxy.getNumber()).toString());
        expect(await proxyContract.getNumber()).to.eq(100);
        expect(await myProxy.getNumber()).to.eq(100);

        
        await proxyContract.setNumber(20);
        expect(await proxyContract.getNumber()).to.eq(20);
        expect(await myProxy.getNumber()).to.eq(20);
    });
});