import React, { useState } from "react";
import { ethers } from "ethers";
import MarketplaceABI from "./frontend/src/abi/Marketplace.json";

const Trade = () => {
  const marketAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
  const [yourTokenId, setYourTokenId] = useState("");
  const [targetAddress, setTargetAddress] = useState("");
  const [desiredTokenId, setDesiredTokenId] = useState("");
  const [tradeId, setTradeId] = useState("");

  const createTrade = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const market = new ethers.Contract(marketAddress, MarketplaceABI.abi, signer);
    const tx = await market.createTradeOffer(yourTokenId, targetAddress, desiredTokenId);
    await tx.wait();
    alert("Trade offer created!");
  };

  const acceptTrade = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const market = new ethers.Contract(marketAddress, MarketplaceABI.abi, signer);
    const tx = await market.acceptTrade(tradeId);
    await tx.wait();
    alert("Trade accepted successfully!");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-900 to-purple-800 text-white flex flex-col items-center justify-center">
      <h1 className="text-4xl font-bold mb-8">🔁 Trade NFTs</h1>

      <div className="bg-white/10 p-6 rounded-lg w-[350px] mb-6">
        <h2 className="text-xl font-semibold mb-4">Create Trade Offer</h2>
        <input
          placeholder="Your Token ID"
          value={yourTokenId}
          onChange={(e) => setYourTokenId(e.target.value)}
          className="w-full mb-2 p-2 rounded text-black"
        />
        <input
          placeholder="Target Player Address"
          value={targetAddress}
          onChange={(e) => setTargetAddress(e.target.value)}
          className="w-full mb-2 p-2 rounded text-black"
        />
        <input
          placeholder="Desired Token ID"
          value={desiredTokenId}
          onChange={(e) => setDesiredTokenId(e.target.value)}
          className="w-full mb-3 p-2 rounded text-black"
        />
        <button
          onClick={createTrade}
          className="bg-blue-600 hover:bg-blue-700 w-full py-2 rounded-lg font-bold"
        >
          Create Trade
        </button>
      </div>

      <div className="bg-white/10 p-6 rounded-lg w-[350px]">
        <h2 className="text-xl font-semibold mb-4">Accept Trade Offer</h2>
        <input
          placeholder="Trade ID"
          value={tradeId}
          onChange={(e) => setTradeId(e.target.value)}
          className="w-full mb-3 p-2 rounded text-black"
        />
        <button
          onClick={acceptTrade}
          className="bg-green-600 hover:bg-green-700 w-full py-2 rounded-lg font-bold"
        >
          Accept Trade
        </button>
      </div>
    </div>
  );
};

export default Trade;
