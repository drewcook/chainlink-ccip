/**
 * Mint an NFT on one chain and pay for minting on another, from Avalanche Fuji to Ethereum Sepolia via a burn/mint mechanism. The incoming CCIP message is set to transfer over the 100 units of CCIP-BnM token which is used to pay for the minting price for a new CCIPCustomNFT. The CCIP Message data contains the `mintToken(address)` function signature, and the _ccipReceive() method simple calls it. The NFT will be minted on Sepolia and should be owned by the address who initiates the CCIP message from the sender contract on Fuji.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CCIPCustomNFT is ERC721URIStorage, OwnerIsCreator {
    string constant TOKEN_URI = "https://ipfs.io/ipfs/QmYuKY45Aq87LeL1R5dhb1hqHLp6ZFbJaCP8jxqKM1MX6y/babe_ruth_1.json";
    uint256 tokenId;

    constructor() ERC721("CCIPCustomNFT", "CCIPNFT") {}

    // Allow only the owner of the contract to mint a token to any address
    function mintToken(address _to) public onlyOwner {
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        unchecked {
            tokenId++;
        }
    }
}

contract CCIPTokenAndDataReceiver is CCIPReceiver, OwnerIsCreator {
    CCIPCustomNFT public nft;
    uint256 price;

    mapping(uint64 => bool) public whitelistedSourceChains;
    mapping(address => bool) public whitelistedSenders;

    error CCIPTokenAndDataReceiver__SourceChainNotWhitelisted(uint64 sourceChainSelector);
    error CCIPTokenAndDataReceiver__SenderNotWhitelisted(address sender);

    event MintCallSuccessful();

    modifier onlyWhitelistedSourceChains(uint64 _sourceChainSelector) {
        if (!whitelistedSourceChains[_sourceChainSelector]) {
            revert CCIPTokenAndDataReceiver__SourceChainNotWhitelisted(_sourceChainSelector);
        }
        _;
    }

    modifier onlyWhitelisteSenders(address _sender) {
        if (!whitelistedSenders[_sender]) {
            revert CCIPTokenAndDataReceiver__SenderNotWhitelisted(_sender);
        }
        _;
    }

    constructor(address _router, uint256 _price) CCIPReceiver(_router) {
        price = _price;
    }

    function whitelistSourceChain(uint64 _sourceChainSelector) external onlyOwner {
        whitelistedSourceChains[_sourceChainSelector] = true;
    }

    function denySourceChain(uint64 _sourceChainSelector) external onlyOwner {
        whitelistedSourceChains[_sourceChainSelector] = false;
    }

    function whitelistSender(address _sender) external onlyOwner {
        whitelistedSenders[_sender] = true;
    }

    function denySender(address _sender) external onlyOwner {
        whitelistedSenders[_sender] = false;
    }

    function _ccipReceive(Client.Any2EVMMessage memory _message)
        internal
        override
        onlyWhitelistedSourceChains(_message.sourceChainSelector)
        onlyWhitelisteSenders(abi.decode(_message.sender, (address)))
    {
        require(_message.destTokenAmounts[0].amount >= price, "Not enough tokens (CCIP-BnM) sent to cover mint price");
        (bool success,) = address(nft).call(_message.data);
        require(success, "Mint call failed");
        emit MintCallSuccessful();
    }
}
