const { ethers, upgrades } = require("hardhat");

async function main() {
  const tomiStaking = await ethers.getContractFactory(
    "tomiStaking"
  );
  console.log("Upgrading tomiStaking...");
  await upgrades.upgradeProxy(
    "0x5F9F0a1746371a3747c77Da7E7d6f46DA2390A3b", // old address
    tomiStaking
  );
  console.log("Upgraded Successfully");
}

main();