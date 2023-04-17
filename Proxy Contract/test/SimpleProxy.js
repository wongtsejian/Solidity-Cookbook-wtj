const { expect } = require("chai");
const { ethers } = require("hardhat");

let proxy, logic;
async function deployContracts() {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    let Proxy = await ethers.getContractFactory("SimpleProxy");
    proxy = await Proxy.deploy();
    let Logic = await ethers.getContractFactory("ProxyImplementation");
    logic = await Logic.deploy();

    console.log("Proxy deployed at: ", proxy.address);
    console.log("Logic deployed at: ", logic.address);

}

describe("SimpleProxy", async function () {
    before(async () => {
        await deployContracts();
    });

    it("Set logic", async () => {
        await proxy.setImplementation(logic.address);
    });

    it("Testing Simple Proxy call", async () => {
        await proxy.setImplementation(logic.address);
        const Implementation = await ethers.getContractFactory("ProxyImplementation");
        const proxyContract = await Implementation.attach(
            proxy.address // The deployed contract address
        );

        // sets storage vars in logic contract.
        // await logic.setNumber(30); 
        // console.log("Base: ", (await logic.getNumber()).toString());
        // expect(await logic.getNumber()).to.eq(30);
        console.log("1");
        await proxyContract.setNumber(20);
        console.log("proxyContract Implementation: ", await proxy.getImplementation());
        
        expect (await logic.getNumber()).to.eq(20);

        // let returnVar = await proxyContract.getNumber()

        // console.log("rreturnVar: ", returnVar.toString());
        // expect(returnVar).to.eq(20);

        // console.log("2");
        // await proxy.setImplementation(logic.address);
        // await proxyContract.setNumber(30);
        // expect(await proxyContract.getNumber()).to.eq(30);

        // console.log("3");
        // await proxyContract.setNumber(40);
        // console.log("4");
        // expect(await proxyContract.getNumber()).to.eq(20);
        // console.log("5");
    });


    // it("Testing Simple Proxy Call in another way", async () => {
     
    //     const Implementation = await ethers.getContractFactory("ProxyImplementation");
    //     const proxyContract = await Implementation.attach(
    //         proxy.address // The deployed contract address
    //     );  
        
    //     const myProxy = new ethers.Contract(
    //         proxy.address,       
    //         ["function setNumber(uint _number) external", 
    //         "function getNumber() external view returns(uint)"],
    //         owner
    //     );

    //     await myProxy.setNumber(100);
    //     console.log("My Proxy: ", (await myProxy.getNumber()).toString());
    //     // expect(await proxyContract.getNumber()).to.eq(100);
    //     // expect(await myProxy.getNumber()).to.eq(100);

        
    //     // await proxyContract.setNumber(20);
    //     // expect(await proxyContract.getNumber()).to.eq(20);
    //     // expect(await myProxy.getNumber()).to.eq(20);
     
    // });

});