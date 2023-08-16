// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPReceiver_Unsafe} from "../src/CCIPReceiver_Unsafe.sol";

contract DeployCCIPReceiver_Unsafe is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Ethereum Sepolia's router: https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
        address router = 0xD0daae2231E9CB96b94C8512223533293C3693Bf;

        CCIPReceiver_Unsafe receiver = new CCIPReceiver_Unsafe(router);
        console.log("CCIPReceiver_Unsafe deployed at: %s", address(receiver));

        vm.stopBroadcast();
    }
}
