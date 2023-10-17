import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
const { ethers: myEthers } = require('ethers');

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
        const TestToken = await ethers.getContractFactory("TestToken");
        const testTokenInstance = await TestToken.deploy();

        // Call setCoreAddresses on CollateralHubV3 and initializer()
        const setCoreAddressesTx = await collateralHubV3Instance.setCoreAddresses(
            nuonControllerV3Instance.target, nlpEthInstance.target, nuonInstance.target, testTokenInstance.target);
        await setCoreAddressesTx.wait(); // Wait for the transaction to be mined
        const initializerTx = await collateralHubV3Instance.initialize(100);
        await initializerTx.wait();

        // Call nuonControllerV3's setEcosystemParametersForCHUBS()
        const parsedValue = myEthers.parseUnits("500000000000000000", 18);
        const parsedValue2 = myEthers.parseUnits("111111111100000000", 18);
        const setEcosystemParametersForCHUBSTx = await nuonControllerV3Instance.setEcosystemParametersForCHUBS(
            collateralHubV3Instance.target, parsedValue, 0, parsedValue, parsedValue2, 1, -900, 900, 1, 1);
        await setEcosystemParametersForCHUBSTx.wait();

        // Call NLP-ETH's setCHUBForNLP()
        const setCHUBForNLPTx = await nlpEthInstance.setCHUBForNLP(collateralHubV3Instance.target);
        await setCHUBForNLPTx.wait();

        return { collateralHubV3Instance, nuonControllerV3Instance, nlpEthInstance, owner, nuonInstance, testTokenInstance };
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
                const parsedValue = myEthers.parseUnits("142857142857142860", 18);
                const parsedValue2 = myEthers.parseUnits("10686511125330335", 18);
                const mintTx = await collateralHubV3Instance.mint(parsedValue, parsedValue2);
                await mintTx.wait();
                expect(mintTx).to.emit(collateralHubV3Instance, "First3RequiresPassed");
            });

        it("Should fail minting when minting is paused", async function () {
            const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
            const toggleTx = await nuonControllerV3Instance.toggleMinting();
            await toggleTx.wait();
            const parsedValue = myEthers.parseUnits("142857142857142860", 18);
            const parsedValue2 = myEthers.parseUnits("10686511125330335", 18);
            await expect(collateralHubV3Instance.mint(parsedValue, parsedValue2)).to.be.revertedWith("CHUB: Minting paused!");
        });
    });
    // it("Should fail minting when collateral ratio is out of bounds", async function () {
    //     const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
    //     await expect(collateralHubV3Instance.mint(700, 1000)).to.be.revertedWith("Collateral Ratio out of bounds");
    // });

    // it("Should fail minting when collateral ratio is too low", async function () {
    //     const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
    //     await expect(collateralHubV3Instance.mint(80, 1000)).to.be.revertedWith("Collateral Ratio too low");
    // });

    // it("Should fail minting when user already has a position", async function () {
    //     const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
    //     const tx = await collateralHubV3Instance.mint(300, 1000);
    //     await tx.wait();
    //     // Try to mint again.
    //     await expect(collateralHubV3Instance.mint(350, 2000)).to.be.revertedWith("You already have a position");
    // });

    // it("Should update mappings when user mints NUON", async function () {
    //     const { collateralHubV3Instance, nuonControllerV3Instance, nlpEthInstance, owner } = await loadFixture(deployFixture);
    //     const mintTx = await collateralHubV3Instance.mint(300, 1000);
    //     await mintTx.wait();
    //     // Check that the mappings are updated
    //     const userNLPId = await collateralHubV3Instance.nlpPerUser(owner);
    //     const userCheck = await collateralHubV3Instance.nlpCheck(owner);
    //     const mintedAmount = await collateralHubV3Instance.mintedAmount(owner);
    //     const usersAmounts = await collateralHubV3Instance.usersAmounts(owner);
    //     expect(userNLPId).to.equal(0);
    //     expect(userCheck).to.equal(true);
    //     //expect(Number(mintedAmount)).to.be.gt(0);
    //     expect(Number(usersAmounts)).to.be.gt(0);
    //     console.log(`usersAmounts!: ${usersAmounts}`);
    // });

    describe("Redeem", function () {
        it("Passing",
            async function () {
                const { collateralHubV3Instance, nuonControllerV3Instance } = await loadFixture(deployFixture);
                const parsedValue = myEthers.parseUnits("142857142857142860", 18);
                const parsedValue2 = myEthers.parseUnits("10686511125330335", 18);
                const mintTx = await collateralHubV3Instance.mint(parsedValue, parsedValue2); await mintTx.wait();
                const redeemAmount = myEthers.parseUnits("1000000000000000000", 18);

                const redeemTx = await collateralHubV3Instance.redeem(redeemAmount);
                const receipt = await redeemTx.wait();


                const log = receipt.logs[5];
                console.log("Logs:", log);

                // Assuming parsedLogs is the array you obtained from parsing the logs
                //const redeemedEvent = log.find(x => x.name === 'Redeemed');

                const redeemedEvent = log["args"];

                const sender = redeemedEvent[0];
                const fullAmount = redeemedEvent[1];
                const NUONAmount = redeemedEvent[2];

                console.log("Sender:", sender);
                console.log("Full Amount:", fullAmount.toString()); // Convert to string to handle BigInt
                console.log("NUON Amount:", NUONAmount.toString()); // Convert to string to handle BigInt
            });
    });
});