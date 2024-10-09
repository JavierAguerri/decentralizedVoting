import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            { version: "0.8.0" },
            { version: "0.8.26" },
        ]
    },
    gasReporter: {
        enabled: true,
        reportPureAndViewMethods: true
    }
};

export default config;
