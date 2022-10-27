const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { assert, expect } = require("chai");
//const { inputToConfig } = require("@ethereum-waffle/compiler");
describe("FundMe", async function () {
    let fundMe;
    let deployer;
    let mockV3Aggregator;
    beforeEach(async function () {
        //deploy our fundMe contract
        //using Hardhat-deploy
        //const accounts = await ethers.getSigners(); this will call list the of accounts in any network account we specify
        //deployer = accounts[0]
        deployer = (await getNamedAccounts()).deployer;
        await deployments.fixture(["all"]);
        fundMe = await ethers.getContract("FundMe", deployer); //Here we connect the deployer to fundMe i.e. whenever we call any function with fundMe, it would be automatically be from deployer account
        mockV3Aggregator = await ethers.getContract(
            "mockV3Aggregator",
            deployer
        );
    });

    describe("constructor", async function () {
        it("sets the aggregator addresses correctly", async function () {
            const response = await fundMe.priceFeed();
            assert.equal(response, mockV3Aggregator.address);
        });
    });

    describe("fund", async function () {
        it("Fails if you don't send enough ETH", async function () {
            await expect(fundMe.fund()).to.be.revertedWith(
                "You need to spend more ETH"
            );
        });
    });
});
