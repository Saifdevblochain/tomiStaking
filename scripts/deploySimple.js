const { ethers } = require("hardhat");
const { network, run } = require("hardhat");

async function verify(address, constructorArguments) {
  console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`)
  await run("verify:verify", {
    address,
    constructorArguments
  })
}

async function main() {
  const PioneerNFT_ = await ethers.getContractFactory("PioneerNFT");
  const PioneerNFT = await PioneerNFT_.deploy();
  await PioneerNFT.deployed();

  console.log(`PioneerNFT deployed to ${PioneerNFT.address}`);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(PioneerNFT.address, []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
