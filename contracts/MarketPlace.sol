// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Marketplace
 * @dev Decentralized NFT marketplace for buying/selling NFTs using QuizToken (ERC20)
 *      and for direct player-to-player NFT trades.
 */
contract Marketplace is Ownable {
    IERC20 public quizToken;
    IERC721 public gameAsset;

    struct Listing {
        address seller;
        uint256 price; // in QZT tokens
        bool active;
    }

    struct TradeOffer {
        address from;
        address to;
        uint256 offeredTokenId;
        uint256 requestedTokenId;
        bool active;
    }

    mapping(uint256 => Listing) public listings;     // tokenId => Listing
    mapping(uint256 => TradeOffer) public tradeOffers; // tradeId => Offer
    uint256 public tradeCount;

    event AssetListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event AssetSold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event AssetDelisted(uint256 indexed tokenId);
    event TradeCreated(uint256 indexed tradeId, address indexed from, address indexed to);
    event TradeAccepted(uint256 indexed tradeId);
    event TradeCancelled(uint256 indexed tradeId);

    constructor(address _quizToken, address _gameAsset) Ownable(msg.sender){
        quizToken = IERC20(_quizToken);
        gameAsset = IERC721(_gameAsset);
    }

    /**
     * @dev List an NFT for sale.
     * @param tokenId NFT ID to sell.
     * @param price Price in QuizToken (QZT).
     */
    function listAsset(uint256 tokenId, uint256 price) external {
        require(gameAsset.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(price > 0, "Invalid price");
        require(listings[tokenId].active == false, "Already listed");

        gameAsset.transferFrom(msg.sender, address(this), tokenId);
        listings[tokenId] = Listing(msg.sender, price, true);

        emit AssetListed(tokenId, msg.sender, price);
    }

    /**
     * @dev Buy an NFT listed on the marketplace.
     * @param tokenId NFT ID to purchase.
     */
    function buyAsset(uint256 tokenId) external {
        Listing memory item = listings[tokenId];
        require(item.active, "Not for sale");
        require(
            quizToken.allowance(msg.sender, address(this)) >= item.price,
            "Insufficient token allowance"
        );
        require(
            quizToken.balanceOf(msg.sender) >= item.price,
            "Insufficient token balance"
        );

        // Transfer payment
        quizToken.transferFrom(msg.sender, item.seller, item.price);

        // Transfer NFT
        gameAsset.transferFrom(address(this), msg.sender, tokenId);

        listings[tokenId].active = false;

        emit AssetSold(tokenId, msg.sender, item.price);
    }

    /**
     * @dev Cancel a listing and return NFT to seller.
     * @param tokenId NFT ID to cancel listing for.
     */
    function cancelListing(uint256 tokenId) external {
        Listing memory item = listings[tokenId];
        require(item.active, "Not listed");
        require(item.seller == msg.sender, "Not your listing");

        gameAsset.transferFrom(address(this), msg.sender, tokenId);
        listings[tokenId].active = false;

        emit AssetDelisted(tokenId);
    }

    /**
     * @dev Create a trade offer between two players.
     * @param yourTokenId NFT ID you are offering.
     * @param targetPlayer Address of the player you want to trade with.
     * @param desiredTokenId NFT ID you want in return.
     */
    function createTradeOffer(
        uint256 yourTokenId,
        address targetPlayer,
        uint256 desiredTokenId
    ) external {
        require(gameAsset.ownerOf(yourTokenId) == msg.sender, "You don't own this NFT");
        tradeCount++;

        tradeOffers[tradeCount] = TradeOffer({
            from: msg.sender,
            to: targetPlayer,
            offeredTokenId: yourTokenId,
            requestedTokenId: desiredTokenId,
            active: true
        });

        emit TradeCreated(tradeCount, msg.sender, targetPlayer);
    }

    /**
     * @dev Accept an active trade offer.
     * @param tradeId ID of the trade to accept.
     */
    function acceptTrade(uint256 tradeId) external {
        TradeOffer storage offer = tradeOffers[tradeId];
        require(offer.active, "Trade not active");
        require(msg.sender == offer.to, "Not authorized");
        require(gameAsset.ownerOf(offer.requestedTokenId) == msg.sender, "You don't own the requested NFT");

        // Perform swap
        gameAsset.transferFrom(offer.from, msg.sender, offer.offeredTokenId);
        gameAsset.transferFrom(msg.sender, offer.from, offer.requestedTokenId);

        offer.active = false;

        emit TradeAccepted(tradeId);
    }

    /**
     * @dev Cancel a pending trade offer.
     * @param tradeId ID of the trade to cancel.
     */
    function cancelTrade(uint256 tradeId) external {
        TradeOffer storage offer = tradeOffers[tradeId];
        require(offer.active, "Trade not active");
        require(offer.from == msg.sender, "Only creator can cancel");

        offer.active = false;

        emit TradeCancelled(tradeId);
    }

    /**
     * @dev Get trade offer details.
     * @param tradeId ID of the trade to view.
     */
    function getTradeOffer(uint256 tradeId)
        external
        view
        returns (TradeOffer memory)
    {
        return tradeOffers[tradeId];
    }
}
