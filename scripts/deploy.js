import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  // Deploy QuizToken
  const QuizToken = await hre.ethers.getContractFactory("QuizToken");
  const quizToken = await QuizToken.deploy();
  await quizToken.waitForDeployment();
  console.log("QuizToken deployed at:", await quizToken.getAddress());

  // Deploy GameAsset
  const GameAsset = await hre.ethers.getContractFactory("GameAsset");
  const gameAsset = await GameAsset.deploy();
  await gameAsset.waitForDeployment();
  console.log("GameAsset deployed at:", await gameAsset.getAddress());

  // Deploy Marketplace
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(
    await quizToken.getAddress(),
    await gameAsset.getAddress()
  );
  await marketplace.waitForDeployment();
  console.log("Marketplace deployed at:", await marketplace.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
