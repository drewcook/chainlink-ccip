// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
// import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

// contract CCIPSender_Unsafe {
//     function send(
//         address receiver,
//         uint64 destinationChainSelector,
//         string memory someText
//     ) external {
//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(receiver),
//             data: abi.encode(someText),
//             tokenAmounts: new Client.EVMTokenAmount[](0),
//             extraArgs: "",
//             feeTOken: 0x1 // link
//         });

//         IRouterClient(receiver).ccipSend(destinationChainSelector, message);
//     }
// }
