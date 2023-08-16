// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPTokenAndDataSender} from "../src/CCIPTokenAndDataSender.sol";

// Deploy the CCIPTokenAndDataSender contract to Fuji
contract DeployCCIPTokenAndDataSender is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying CCIPTokenAndDataSender contract to Avalanche Fuji...");

        address fujiLink = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
        address fujiRouter = 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;

        CCIPTokenAndDataSender ccipTokenAndDataSender = new CCIPTokenAndDataSender(
                fujiLink,
                fujiRouter
            );

        console.log("CCIPTokenAndDataSender deployed at: %s", address(ccipTokenAndDataSender));

        vm.stopBroadcast();
    }
}
