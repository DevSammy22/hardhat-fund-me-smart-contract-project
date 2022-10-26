const { network } = require("hardhat");
//In hardhat deploy, we would not be having main function or calling a function
//When we run hardhat deploy, it would call any function we specify
// async function deployFunc(hre){
// console.log("Hi");
// hre.getNamedAccounts();
// hre.deployments;
// //}
// module.exports.default = deployFunc

//module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre;
// };

const { networkConfig } = require("../helper-hardhat-config");
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deploye } = await getNamedAccounts();
    const chainId = network.config.chainId;

    //if chainId is X, we use address Y
    //if chainId is B, we use address A
    const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
};
