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

  let tomi = "0x3F28F5C870dD87c988711032E2750D0f1408AE6a"
  let minPioneer = "0xBa46f28888040Ddb2c7D5143C8d4881A0C3a6CF9"
  let Pioneer = "0xEDfD2316367A430CecFA91e16E761E6aeF01E5Ce"

  const tomiStaking = await ethers.getContractFactory(
    "tomiStaking"
  );
  console.log("Deploying tomiStaking...");
  const contract = await upgrades.deployProxy(tomiStaking, [
    tomi,
    Pioneer,
    minPioneer
  ], {
    initializer: "initialize",
    kind: "transparent",
  });
  await contract.deployed();
  console.log("tomiStaking deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(contract.address, [])
}

main();

 