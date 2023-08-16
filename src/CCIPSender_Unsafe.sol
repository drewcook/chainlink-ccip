/**
 * Sending a CCIP Message from Avalanche Fuji to Ethereum Sepolia. The message will contain a generic string message and will pay for the CCIP fees in LINK.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract CCIPSender_Unsafe {
    address link;
    address router;

    constructor(address _link, address _router) {
        link = _link;
        router = _router;
        // UNSAFE - approving the Router.sol contract to spend the max amount of LINK tokens that this contract poses
        LinkTokenInterface(link).approve(router, type(uint256).max);
    }

    // Send a CCIP message
    function sendMessage(uint64 _destinationChainSelector, address _receiver, string memory _message) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_message),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            feeToken: link,
            extraArgs: ""
        });
        IRouterClient(router).ccipSend(_destinationChainSelector, message);
    }
}
