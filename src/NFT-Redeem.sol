// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts v5.0.0
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MeetContract is ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;
    string private _currentBaseURI; // Added to store the current base URI

    uint256 public totalNumberOfTokens = 0;

    event TokenMinted(address indexed to, uint256 indexed tokenId, string uri);
    event TokenBurned(uint256 indexed tokenId);

    constructor() ERC721("Meet", "MET") Ownable(msg.sender) {
        _nextTokenId = 1;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit TokenMinted(to, tokenId, uri);
        totalNumberOfTokens++;
    }

    function burn(uint256 tokenId) public override(ERC721Burnable) {
        require(msg.sender == ownerOf(tokenId) || msg.sender == owner(), "Caller is not owner nor NFT owner");
        super.burn(tokenId);
        emit TokenBurned(tokenId);
        totalNumberOfTokens--;
    }

    // Public function to update the base URI, restricted to the contract owner
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _currentBaseURI = newBaseURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual override(ERC721URIStorage) {
        super._setTokenURI(tokenId, _tokenURI);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _currentBaseURI;
    }
}
