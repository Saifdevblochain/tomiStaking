const { ethers, upgrades } = require("hardhat");

async function main() {
  const Tomi = await ethers.getContractFactory(
    "Tomi"
  );
  console.log("Upgrading Tomi...");
  await upgrades.upgradeProxy(
    "0x7363Ee9a65EB345A57b3823d052880EFdfc995D7", // old address
    FxStateRootTunnel
  );
  console.log("Upgraded Successfully");
}

main();