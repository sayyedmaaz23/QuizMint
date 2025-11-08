// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    IERC20 public quizToken;
    IERC721 public gameAsset;

    struct Listing {
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    event Listed(uint256 tokenId, uint256 price);
    event Sold(uint256 tokenId, address buyer);

    constructor(address _quizToken, address _gameAsset) Ownable(msg.sender){
        quizToken = IERC20(_quizToken);
        gameAsset = IERC721(_gameAsset);
    }

    // Owner lists NFTs for sale
    function listAsset(uint256 tokenId, uint256 price) external onlyOwner {
        require(gameAsset.ownerOf(tokenId) == owner(), "NFT not owned by owner");
        require(price > 0, "Invalid price");
        listings[tokenId] = Listing(tokenId, price, true);
        emit Listed(tokenId, price);
    }

    // Player buys from owner using QZT tokens
    function buyAsset(uint256 tokenId) external {
        Listing storage item = listings[tokenId];
        require(item.active, "Not listed");

        // Player must approve marketplace before purchase
        bool ok = quizToken.transferFrom(msg.sender, owner(), item.price);
        require(ok, "Payment failed");

        gameAsset.safeTransferFrom(owner(), msg.sender, tokenId);
        item.active = false;

        emit Sold(tokenId, msg.sender);
    }
}
