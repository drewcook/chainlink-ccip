// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPTokenAndDataReceiver} from "../src/CCIPTokenAndDataReceiver.sol";

// Deploy the CCIPTokenAndDataReceiver contract to Sepolia
contract DeployCCIPTokenAndDataReceiver is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying CCIPTokenAndDataReceiver contract to Ethereum Sepolia...");

        address sepoliaRouter = 0xD0daae2231E9CB96b94C8512223533293C3693Bf;
        uint256 price = 100; // The NFT price will be 100 units of CCIP-BnM token

        CCIPTokenAndDataReceiver ccipTokenAndDataReceiver = new CCIPTokenAndDataReceiver(
                sepoliaRouter,
                price
            );

        console.log("CCIPTokenAndDataReceiver deployed at: %s", address(ccipTokenAndDataReceiver));

        vm.stopBroadcast();
    }
}
