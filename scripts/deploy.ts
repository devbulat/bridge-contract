
import { ethers } from "hardhat";
import { config } from "dotenv";

config({ path: "/" });

const ethereumToken = process.env.ETHEREUM_TOKEN;
const binanceToken = process.env.BINANCE_TOKEN;

async function main() {
  const ethereumBridgeFactory = await ethers.getContractFactory("EthereumBridge");
  const EthereumBridge = await ethereumBridgeFactory.deploy(ethereumToken);
  const binanceBridgeFactory = await ethers.getContractFactory("BinanceBridge");
  const BinanceBridge = await binanceBridgeFactory.deploy(binanceToken);

  await EthereumBridge.deployed();
  await BinanceBridge.deployed();

  console.log("EthereumBridge deployed to:", EthereumBridge.address);
  console.log("BinanceBridge deployed to:", BinanceBridge.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
