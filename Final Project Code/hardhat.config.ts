import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import dotenv from 'dotenv';


// Protect keys and info.  
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      // Other settings...
    },
  },
  namedAccounts: {
    deployer: 0
  },
  paths: {
    deployments: 'deployments', // Change 'custom_deployments_path' to your desired path
  },
  networks: {
    alchemy: {
      url: process.env.ALCHEMY_URL || "", // Replace with your Alchemy endpoint
      accounts: [process.env.PRIVATE_KEY ?? ""],
      gasPrice: 10000,
    },
    infura: {
      url: process.env.INFURA_SEPOLIA_URL || "", // Your Infura Sepolia endpoint
      accounts: [process.env.PRIVATE_KEY ?? ""],
      gasPrice: 10000,
    },
    base_goerli: {
      url: "https://goerli.base.org",
      accounts:
        // Need a .env file with 
        [process.env.PRIVATE_KEY ?? ""],
      gasPrice: 10000, // Keep this low, don't need my transaction to get included quickly.
      // Upfront cost could be higher if I make this higher.  Doesn't have to do
      // with execution cost/what gets refunded.
    }
  }
};

export default config;
