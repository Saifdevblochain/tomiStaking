const { ethers } = require("hardhat");

const { network, run } = require("hardhat");
const { Contract } = require("hardhat/internal/hardhat-network/stack-traces/model");

async function verify(address, constructorArguments) {
  console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`)
  await run("verify:verify", {
    address,
    constructorArguments
  })
}

async function main() {
  const PioneerNFT = await ethers.getContractFactory(
    "PioneerNFT"
  );
  console.log("Deploying PioneerNFT...");

  const contract = await PioneerNFT.deploy();
  await contract.deployed();
  console.log("PioneerNFT deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(contract.address, [])
}

main();
