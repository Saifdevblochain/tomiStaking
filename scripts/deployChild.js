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

  const FxStateChildTunnel = await ethers.getContractFactory(
    "FxStateChildTunnel"
  );
  console.log("Deploying FxStateChildTunnel...");
  const contract = await upgrades.deployProxy(FxStateChildTunnel, [], {
    initializer: "initialize",
    kind: "transparent",
  });
  await contract.deployed();
  console.log("FxStateChildTunnel deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(contract.address, [])
}

main();

 