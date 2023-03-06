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

  // const tomiStaking = await ethers.getContractFactory(
  //   "tomiStaking"
  // );
  // console.log("Deploying tomiStaking...");
  // const contract = await upgrades.deployProxy(tomiStaking, [], {
  //   initializer: "initialize",
  //   kind: "transparent",
  // });
  // await contract.deployed();
  // console.log("tomiStaking deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify("0x7F0dc60FC01DAA53dc60FCdE01fd091ABe4db8c6", [])
}

main();

 