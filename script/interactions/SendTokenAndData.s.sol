// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPTokenAndDataSender} from "../../src/CCIPTokenAndDataSender.sol";
import {CCIPTokenAndDataReceiver} from "../../src/CCIPTokenAndDataReceiver.sol";

// Run this on Sepolia
contract WhitelistSenderAndFujiAsSourceChain is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fuji: https://testnet.snowtrace.io/address/0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A
        address fujiSender = 0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A;
        // Sepolia: https://sepolia.etherscan.io/address/0xE44aa81Fe6eBb8395BdF320D4BD58E2551dbf2b2
        address sepoliaReceiver = 0xE44aa81Fe6eBb8395BdF320D4BD58E2551dbf2b2;

        // CCIP Chain Selector
        uint64 fujiChainSelector = 14767482510784806043;

        // Whitelist the Fuji sender contract as a sender
        CCIPTokenAndDataReceiver(sepoliaReceiver).whitelistSender(fujiSender);

        // Whitelist the Fuji chain as a source chain
        CCIPTokenAndDataReceiver(sepoliaReceiver).whitelistSourceChain(fujiChainSelector);

        vm.stopBroadcast();
    }
}

// Run this on Fuji
contract WhitelistSepoliaAsDestinationChain is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fuji: https://testnet.snowtrace.io/address/0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A
        address fujiSender = 0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A;

        // CCIP Chain Selector
        uint64 sepoliaChainSelector = 16015286601757825753;

        CCIPTokenAndDataSender(fujiSender).whitelistDestinationChain(sepoliaChainSelector);

        vm.stopBroadcast();
    }
}

// Run this on Fuji
contract MintNFTOnSepoliaAndPayForItOnFuji is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fuji: https://testnet.snowtrace.io/address/0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A
        address fujiSender = 0xDBFdfACAAfbF538cFd8EC39eE985ACf6758cfC5A;
        // Sepolia: https://sepolia.etherscan.io/address/0xE44aa81Fe6eBb8395BdF320D4BD58E2551dbf2b2
        address sepoliaReceiver = 0xE44aa81Fe6eBb8395BdF320D4BD58E2551dbf2b2;

        // CCIP Chain Selector
        uint64 sepoliaChainSelector = 16015286601757825753;

        // CCIP-BnM token used to pay for the NFT mint price
        address fujiCCIPBnMToken = 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4;
        uint256 priceToPayInCCIPBnM = 100; // 0.0000000000000001 tokens

        // Send the CCIP message from Fuji to mint an NFT on Sepolia, pay for it with the LINK and CCIP-BnM that the Fuji sender contract has on it's balance (pre-funded via EOA txs)
        CCIPTokenAndDataSender(fujiSender).transferTokens(
            sepoliaChainSelector, fujiCCIPBnMToken, sepoliaReceiver, priceToPayInCCIPBnM
        );

        vm.stopBroadcast();
    }
}
