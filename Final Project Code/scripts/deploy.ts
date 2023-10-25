import { ethers } from "hardhat";
const { ethers: myEthers } = require('ethers');

async function main() {

  // Deploy Contracts
  const nuonControllerV3 = await ethers.deployContract("NUONControllerV3");
  const collateralHubV3 = await ethers.deployContract("CollateralHubV3");
  const nlpETH = await ethers.deployContract("NuonLiquidPositionsETH");
  const nuon = await ethers.deployContract("NUON");
  const testToken = await ethers.deployContract("TestToken");
  await nuonControllerV3.waitForDeployment(); // Line is extra security confirming transaction is on the network.
  await collateralHubV3.waitForDeployment();
  await nlpETH.waitForDeployment();
  await nuon.waitForDeployment();
  await testToken.waitForDeployment();
  console.log(`NUONControllerV3 deployed to ${nuonControllerV3.target}`);
  console.log(`CollateralHubV3 deployed to ${collateralHubV3.target}`);
  console.log(`NLP-ETH deployed to ${nlpETH.target}`);
  console.log(`NUON deployed to ${nuon.target}`);
  console.log(`TestToken deployed to ${testToken.target}`);

  // Call CollateralHubV3's setCoreAddresses() and initializer()
  const setCoreAddressesTx = await collateralHubV3.setCoreAddresses(nuonControllerV3.target, nlpETH.target, nuon.target, testToken.target);
  await setCoreAddressesTx.wait();
  console.log(`CollateralHubV3 setCoreAddress: ${nuonControllerV3.target}, ${nlpETH.target}, ${nuon.target}, ${testToken.target}`);
  const initializerTx = await collateralHubV3.initialize(100);
  await initializerTx.wait();
  console.log(`CollateralHubV3 Initializer params are set`);

  // Call nuonControllerV3's setEcosystemParametersForCHUBS()
  const parsedValue = myEthers.parseUnits("500000000000000000", 18);
  const parsedValue2 = myEthers.parseUnits("111111111100000000", 18);
  const mintFee = myEthers.parseUnits("000000000000000001", 18);
  const setEcosystemParametersForCHUBSTx = await nuonControllerV3.setEcosystemParametersForCHUBS(
    collateralHubV3.target, parsedValue, 0, parsedValue, parsedValue2, 1, -900, 900, mintFee, 1);
  await setEcosystemParametersForCHUBSTx.wait();
  console.log(`NuonControllerV3's ecosystem params have been set`);


  // Call NLP-ETH's setCHUBForNLP()
  const setCHUBForNLPTx = await nlpETH.setCHUBForNLP(collateralHubV3.target);
  await setCHUBForNLPTx.wait();
  console.log(`NLP-ETH's setCHUBForNLP(CHUB address) has been set to ${collateralHubV3.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
