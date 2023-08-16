// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {CCIPSender_Unsafe} from "../../src/CCIPSender_Unsafe.sol";

contract SendMessage_Unsafe is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fuji: https://testnet.snowtrace.io/address/0x9B5F6Aa927802A8129CdD8d52888020d7EEacA02
        address fujiSender = 0x9B5F6Aa927802A8129CdD8d52888020d7EEacA02;
        // Sepolia: https://sepolia.etherscan.io/address/0x3d5E267de03d53490A7Cf0aB054bB8333A68b963
        address sepoliaReceiver = 0x3d5E267de03d53490A7Cf0aB054bB8333A68b963;
        // CCIP selector for Ethereum Sepolia
        uint64 destinationChainSelector = 16015286601757825753;
        // Our custom, cross-chain message
        string
            memory message = "Hello, it's me. I was wondering if after all these years you'd like to meet.";

        CCIPSender_Unsafe(fujiSender).sendMessage(
            destinationChainSelector,
            sepoliaReceiver,
            message
        );

        vm.stopBroadcast();
    }
}
