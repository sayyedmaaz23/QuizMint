import hre from "hardhat";

async function main() {
  const [owner] = await hre.ethers.getSigners();
  console.log("Deploying with owner:", owner.address);

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

  // Mint NFTs to owner
  const uris = [
    "ipfs://bafkreifewgdl2mi4jbvzctd5jnnubnhnzqgsedravj7r5r4l6h64akjw7u",
    "ipfs://bafkreib3inqzlinxw6mtnyre7sx655mbdikmtvrvumtre5jrx6tou7cdrm",
    "ipfs://bafkreif5i2jlcfofqshivqvwsb2hrjwag4yjvevc6cel6vyn35mpdkosgu",
    "ipfs://bafkreidh7yozaatssbcq6amdlnryoz5etxfrbrycel46nxeudiaewsmwde"
  ];
for (let uri of uris) {
  const tx = await gameAsset.mint(owner.address, uri);
  await tx.wait();
  console.log(`✅ Minted NFT with URI: ${uri}`);
}


  // Deploy Marketplace
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(
    await quizToken.getAddress(),
    await gameAsset.getAddress()
  );
  await marketplace.waitForDeployment();
  console.log("Marketplace deployed at:", await marketplace.getAddress());

  // Approve and list NFTs
for (let i = 0; i < uris.length; i++) {
  await gameAsset.approve(await marketplace.getAddress(), i);
  const listTx = await marketplace.listAsset(i, hre.ethers.parseUnits("5", 18));
  await listTx.wait();
  console.log(`🛒 NFT ${i} listed at 5 QZT`);
}

}

main().catch(console.error);
