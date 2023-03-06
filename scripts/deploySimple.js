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
  const tomiStaking = await ethers.getContractFactory(
    "tomiStaking"
  );
  console.log("Deploying tomiStaking...");

  const contract = await tomiStaking.deploy("0x3a06cF44DFC0010350F4F6F339d01a6f258AD9D0");
  await contract.deployed();
  console.log("tomiStaking deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(contract.address, ["0x3a06cF44DFC0010350F4F6F339d01a6f258AD9D0"])
}

main();
