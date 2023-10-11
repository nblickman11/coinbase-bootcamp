import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("CollateralHubV3", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployFixture() {

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        // Returns a JS object, contract factory, which allows deployment and instance creation.
        const collateralHubV3 = await ethers.getContractFactory("CollateralHubV3");
        const collateralHubV3Instance = await collateralHubV3.deploy();
        const NUONControllerV3 = await ethers.getContractFactory("NUONControllerV3");
        const nuonControllerV3Instance = await NUONControllerV3.deploy();
        const NLP_ETH = await ethers.getContractFactory("NuonLiquidPositionsETH");
        const nlpEthInstance = await NLP_ETH.deploy();
        const NUON = await ethers.getContractFactory("NUON");
        const nuonInstance = await NUON.deploy();

        // Call setCoreAddresses on CollateralHubV3 and initializer()
        const setCoreAddressesTx = await collateralHubV3Instance.setCoreAddresses(
            nuonControllerV3Instance.target, nlpEthInstance.target, nuonInstance.target);
        await setCoreAddressesTx.wait(); // Wait for the transaction to be mined
        const initializerTx = await collateralHubV3Instance.initialize(1000000);
        await initializerTx.wait();

        // Call nuonControllerV3's setEcosystemParametersForCHUBS()
        const setEcosystemParametersForCHUBSTx = await nuonControllerV3Instance.setEcosystemParametersForCHUBS(
            collateralHubV3Instance.target, 500, 100, 100, 200, 6, 10, -10, 1);
        await setEcosystemParametersForCHUBSTx.wait();

        // Call NLP-ETH's setCHUBForNLP()
        const setCHUBForNLPTx = await nlpEthInstance.setCHUBForNLP(collateralHubV3Instance.target);
        await setCHUBForNLPTx.wait();

        return { collateralHubV3Instance, nuonControllerV3Instance, nlpEthInstance, owner, nuonInstance };
    }

    describe("Deployment", function () {
        it("Confirm correct Controller address is set", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
            expect(await collateralHubV3Instance.NUONController()).to.equal(nuonControllerV3Instance.target);
        });
    });

    describe("Mint", function () {
        it("Should pass minting first 3 require statement's when not paused and within collateral ratio bounds",
            async function () {
                const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
                const mintTx = await collateralHubV3Instance.mint(300, 1000);
                await mintTx.wait();
                expect(mintTx).to.emit(collateralHubV3Instance, "First3Requirespassed");
            });

        it("Should fail minting when minting is paused", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
            const toggleTx = await nuonControllerV3Instance.toggleMinting();
            await toggleTx.wait();
            await expect(collateralHubV3Instance.mint(300, 1000)).to.be.revertedWith("CHUB: Minting paused!");
        });

        it("Should fail minting when collateral ratio is out of bounds", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
            await expect(collateralHubV3Instance.mint(700, 1000)).to.be.revertedWith("Collateral Ratio out of bounds");
        });

        it("Should fail minting when collateral ratio is too low", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
            await expect(collateralHubV3Instance.mint(80, 1000)).to.be.revertedWith("Collateral Ratio too low");
        });

        // it("Should fail minting when user already has a position", async function () {
        //     const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
        //     const tx = await collateralHubV3Instance.mint(300, 1000);
        //     await tx.wait();
        //     // Try to mint again.
        //     await expect(collateralHubV3Instance.mint(350, 2000)).to.be.revertedWith("You already have a position");
        // });

        it("Should update mappings when user mints NUON", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance, nlpEthInstance, owner } = await loadFixture(deployFixture);
            const mintTx = await collateralHubV3Instance.mint(300, 1000);
            await mintTx.wait();
            // Check that the mappings are updated
            const userNLPId = await collateralHubV3Instance.nlpPerUser(owner);
            const userCheck = await collateralHubV3Instance.nlpCheck(owner);
            const mintedAmount = await collateralHubV3Instance.mintedAmount(owner);
            const usersAmounts = await collateralHubV3Instance.usersAmounts(owner);
            expect(userNLPId).to.equal(0);
            expect(userCheck).to.equal(true);
            //expect(Number(mintedAmount)).to.be.gt(0);
            expect(Number(usersAmounts)).to.be.gt(0);
            console.log(`usersAmounts: ${usersAmounts}`);
        });
    });
});