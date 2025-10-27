// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GameAsset
 * @dev ERC721 NFT contract representing unique in-game assets.
 * Each NFT links to metadata hosted on IPFS.
 */
contract GameAsset is ERC721URIStorage, Ownable {
    uint256 private _tokenIds; // acts as a counter

    constructor() ERC721("GameAsset", "GASSET") Ownable(msg.sender){}

    /**
     * @dev Mints a new NFT to the specified player.
     * @param to The wallet address receiving the NFT.
     * @param tokenURI The IPFS URI pointing to the NFT metadata (ipfs://...).
     * @return newItemId The new token ID.
     */
    function mintNFT(address to, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds += 1; // simple counter increment
        uint256 newItemId = _tokenIds;

        _safeMint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    /**
     * @dev Allows owner/admin to burn an NFT (optional cleanup).
     * @param tokenId The token ID to burn.
     */
    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    /**
     * @dev Returns total NFTs minted so far.
     */
    function totalMinted() external view returns (uint256) {
        return _tokenIds;
    }
}
