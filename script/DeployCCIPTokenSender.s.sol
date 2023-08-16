// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPTokenSender} from "../src/CCIPTokenSender.sol";

contract DeployCCIPTokenSender is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying CCIPTokenSender contract to Avalanche Fuji...");

        address fujiLink = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
        address fujiRouter = 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;

        CCIPTokenSender ccipTokenSender = new CCIPTokenSender(
            fujiLink,
            fujiRouter
        );

        console.log(
            "CCIPTokenSender deployed at: %s",
            address(ccipTokenSender)
        );

        vm.stopBroadcast();
    }
}
