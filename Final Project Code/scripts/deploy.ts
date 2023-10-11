import { ethers } from "hardhat";

async function main() {

  // Deploy Contracts
  const nuonControllerV3 = await ethers.deployContract("NUONControllerV3");
  const collateralHubV3 = await ethers.deployContract("CollateralHubV3");
  const nlpETH = await ethers.deployContract("NuonLiquidPositionsETH");
  const nuon = await ethers.deployContract("NUON");
  await nuonControllerV3.waitForDeployment(); // Line is extra security confirming transaction is on the network.
  await collateralHubV3.waitForDeployment();
  await nlpETH.waitForDeployment();
  await nuon.waitForDeployment();
  console.log(`NUONControllerV3 deployed to ${nuonControllerV3.target}`);
  console.log(`CollateralHubV3 deployed to ${collateralHubV3.target}`);
  console.log(`NLP-ETH deployed to ${nlpETH.target}`);
  console.log(`NUON deployed to ${nuon.target}`);

  // Call CollateralHubV3's setCoreAddresses() and initializer()
  const setCoreAddressesTx = await collateralHubV3.setCoreAddresses(nuonControllerV3.target, nlpETH.target, nuon.target);
  await setCoreAddressesTx.wait();
  console.log(`CollateralHubV3 setCoreAddress: ${nuonControllerV3.target}, ${nlpETH.target}, ${nuon.target}`);
  const initializerTx = await collateralHubV3.initialize(1000000000);
  await initializerTx.wait();
  console.log(`CollateralHubV3 Initializer params are set`);

  // Call nuonControllerV3's setEcosystemParametersForCHUBS()
  // **NOTE, THINK SOME OF BELOW PARAMS SHOULD HAVE 18 DECIMAL NUMBERS!!
  const setEcosystemParametersForCHUBSTx = await nuonControllerV3.setEcosystemParametersForCHUBS(
    collateralHubV3.target, 500, 100, 100, 200, 6, 10, -10, 1);
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
