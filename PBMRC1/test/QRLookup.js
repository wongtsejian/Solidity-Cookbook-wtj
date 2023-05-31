// Test script for QRLookup.sol

const { expect } = require("chai");

describe("QRLookup", function () {
  let QRLookup;
  let qrLookup;
  let owner;
  let acquirer1;
  let acquirer2;
  let merchant1;
  let merchant2;
  const organisation1 = "Organisation 1";
  const organisation2 = "Organisation 2";
  const hash1 = "hash1";
  const hash2 = "hash2";

  beforeEach(async function () {
    QRLookup = await ethers.getContractFactory("QRLookup");
    qrLookup = await QRLookup.deploy();
    [owner, acquirer1, acquirer2, merchant1, merchant2] = await ethers.getSigners();
  });

  describe("Contract deployment", function () {
    it("Should set the owner correctly", async function () {
      expect(await qrLookup.getOwner()).to.equal(owner.address);
    });

  });

  describe("Owner functions", function () {
    beforeEach(async function () {
      await qrLookup.addOrganisation(organisation1);
    });

    it("Should add an organisation", async function () {
      expect(await qrLookup.organisationAlreadyRegistered(organisation1)).to.be.true;
    });

    it("Should emit OrganisationAdded event when adding an organisation", async function () {
      expect(await qrLookup.addOrganisation(organisation2))
        .to.emit(qrLookup, "OrganisationAdded")
        .withArgs(organisation2);
    });

    it("Should remove an organisation", async function () {
      await qrLookup.removeOrganisation(organisation1);
      expect(await qrLookup.organisationAlreadyRegistered(organisation1)).to.be.false;
    });

    it("Should emit AcquirerRemoved event when removing an organisation", async function () {
        await qrLookup.addAcquirer(acquirer1.address, organisation1);
        expect(await qrLookup.removeOrganisation(organisation1))
        .to.emit(qrLookup, "AcquirerRemoved")
        .withArgs(acquirer1.address, organisation1);
      });

    it("Should emit OrganisationRemoved event when removing an organisation", async function () {
      expect(await qrLookup.removeOrganisation(organisation1))
        .to.emit(qrLookup, "OrganisationRemoved")
        .withArgs(organisation1);
    });

    it("Should revert when removing a non-existing organisation", async function () {
      await expect(qrLookup.removeOrganisation("NonExistingOrganisation")).to.be.revertedWith(
        "Error: Organisation does not exist."
      );
    });

    it("Should revert when adding an existing organisation", async function () {
      await expect(qrLookup.addOrganisation(organisation1)).to.be.revertedWith("Error: Organisation already exists.");
    });

    
  });

  describe("Acquirer functions", function () {
    beforeEach(async function () {
      await qrLookup.addOrganisation(organisation1);
      await qrLookup.addOrganisation(organisation2);
    });

    it("Should add an acquirer", async function () {
        await qrLookup.addAcquirer(acquirer1.address, organisation1);
        expect(await qrLookup.isAcquirer(acquirer1.address)).to.be.true;
      });
  
    it("Should emit AcquirerAdded event when adding an acquirer", async function () {
    expect(await qrLookup.addAcquirer(acquirer1.address, organisation1))
        .to.emit(qrLookup, "AcquirerAdded")
        .withArgs(acquirer1.address, organisation1);
    });

    it("Should remove an acquirer", async function () {
    await qrLookup.addAcquirer(acquirer1.address, organisation1);
    await qrLookup.removeAcquirer(acquirer1.address);
    expect(await qrLookup.isAcquirer(acquirer1.address)).to.be.false;
    });

    it("Should emit AcquirerRemoved event when removing an acquirer", async function () {
    await qrLookup.addAcquirer(acquirer1.address, organisation1);
    expect(await qrLookup.removeAcquirer(acquirer1.address))
        .to.emit(qrLookup, "AcquirerRemoved")
        .withArgs(acquirer1.address, organisation1);
    });

    it("Should revert when removing a non-existing acquirer", async function () {
    await expect(qrLookup.removeAcquirer(acquirer1.address)).to.be.revertedWith("Error: Not an acquirer.");
    });

    it("Should revert when adding an existing acquirer", async function () {
    await qrLookup.addAcquirer(acquirer1.address, organisation1);
    await expect(qrLookup.addAcquirer(acquirer1.address, organisation2)).to.be.revertedWith("Error: Acquirer already exists.");
    });

    it("Should revert when adding an acquirer to a non-existing organisation", async function () {
    await expect(qrLookup.addAcquirer(acquirer1.address, "NonExistingOrganisation")).to.be.revertedWith(
        "Error: Organisation does not exist."
    );
    });
});

describe("Merchant functions", function () {
    let qrLookupConnected;
    beforeEach(async function () {
    await qrLookup.addOrganisation(organisation1);
    await qrLookup.addAcquirer(acquirer1.address, organisation1);
    qrLookupConnected= await qrLookup.connect(acquirer1);
    });

    it("Should register a merchant QR", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    expect(await qrLookup.getMerchantAddress(hash1)).to.equal(merchant1.address);
    });

    it("Should emit MerchantRegistered event when registering a merchant QR", async function () {
    expect(await qrLookupConnected.registerMerchantQR(hash1, merchant1.address))
        .to.emit(qrLookup, "MerchantRegistered")
        .withArgs(organisation1, hash1, merchant1.address);
    });

    it("Should revert when registering an already registered merchant QR", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    await expect(qrLookupConnected.registerMerchantQR(hash1, merchant1.address)).to.be.revertedWith(
        "Error: Merchant already exists. Please delete existing mapping if you wish to overwrite it."
    );
    });

    it("Should revert when registering a merchant QR by a non-acquirer", async function () {
    await expect(qrLookup.connect(merchant1).registerMerchantQR(hash1, merchant1.address)).to.be.revertedWith(
        "Error: Non-acquirer cannot call this function."
    );
    });

    it("Should deregister a merchant QR", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    await qrLookupConnected.deregisterMerchantQR(hash1);
    await expect(qrLookup.getMerchantAddress(hash1)).to.be.revertedWith("Error: Merchant is not registered.");
    });


    it("Should emit MerchantDeregistered event when deregistering a merchant QR", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    expect(await qrLookupConnected.deregisterMerchantQR(hash1))
        .to.emit(qrLookup, "MerchantDeregistered")
        .withArgs(organisation1, hash1, merchant1.address);
    });

    it("Should revert when deregistering a non-registered merchant QR", async function () {
    await expect(qrLookupConnected.deregisterMerchantQR(hash1)).to.be.revertedWith("Error: Merchant does not exist.");
    });

    it("Should revert when deregistering a merchant QR by a non-acquirer", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    await expect(qrLookup.connect(merchant1).deregisterMerchantQR(hash1)).to.be.revertedWith(
        "Error: Non-acquirer cannot call this function."
    );
    });

    it("Should get the merchant address by providing a hash of the QR_dest_info", async function () {
    await qrLookupConnected.registerMerchantQR(hash1, merchant1.address);
    expect(await qrLookup.getMerchantAddress(hash1)).to.equal(merchant1.address);
    });

    it("Should revert when getting a non-registered hash", async function () {
    await expect(qrLookup.getMerchantAddress("nonRegisteredHash")).to.be.revertedWith("Error: Merchant is not registered.");
    });
});
});