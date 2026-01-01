import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployVendor: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const yourToken = await hre.ethers.getContract<Contract>("YourToken", deployer);
  const yourTokenAddress = await yourToken.getAddress();

  // 1. Deploy Vendor
  const vendorDeployResult = await deploy("Vendor", {
    from: deployer,
    args: [yourTokenAddress],
    log: true,
    autoMine: true,
  });

  const vendor = await hre.ethers.getContract<Contract>("Vendor", deployer);
  const vendorAddress = await vendor.getAddress();

  console.log("\n 🏵  Sending all 1000 tokens to the Vendor...\n");
  const transferTx = await yourToken.transfer(vendorAddress, hre.ethers.parseEther("1000"));
  console.log("   ⏳ Waiting for transfer confirmation...");
  await transferTx.wait(2); 
  console.log("   ✅ Tokens transferred!");

  console.log("\n 🤹  Transferring ownership to frontend address...\n");
  const ownershipTx = await vendor.transferOwnership("0x8BDEe15714D3216756a487F8ad38f5Bc82eb5570");
  console.log("   ⏳ Waiting for ownership transfer confirmation...");
  await ownershipTx.wait(2); 
  console.log("   ✅ Ownership transferred!");
};

export default deployVendor;
deployVendor.tags = ["Vendor"];