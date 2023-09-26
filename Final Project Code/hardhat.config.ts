import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import dotenv from 'dotenv';

// Protect keys and info.  
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0
  },
  networks: {
    base_goerli: {
      url: "https://goerli.base.org",
      accounts: {
        // Need a .env file with 
            //MNENOMIC="<REPLACE WITH YOUR MNEMONIC>"
            // ALCHEMY_GOERLI_KEY=<REPLACE WITH YOUR API KEY>
        mnemonic: process.env.MNEMONIC ?? ""
      }
    }
  }
};

export default config;
