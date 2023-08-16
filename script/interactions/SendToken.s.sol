// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CCIPTokenSender} from "../../src/CCIPTokenSender.sol";

contract SendCCIPBnMToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Construct the paramters to send the CCIP-BnM token from Fuji to an EOA on Sepolia
        uint64 sepoliaChainSelector = 16015286601757825753;
        address fujiCCIPBnMToken = 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4;
        address receiver = 0x847F115314b635F58A53471768D14E67e587cb56;
        uint256 amount = 100; // 0.0000000000000001 tokens

        // Interact with the deployed CCIPTokenSender contract on Fuji
        address fujiSender = 0xD5EDF980a866Fc87E2F578777a50a8dEC78B6A2F;

        // Whitelist the Sepolia destination chain
        CCIPTokenSender(fujiSender).whitelistDestinationChain(sepoliaChainSelector);

        // Send the CCIP Message
        CCIPTokenSender(fujiSender).transferTokens(sepoliaChainSelector, fujiCCIPBnMToken, receiver, amount);

        vm.stopBroadcast();
    }
}
