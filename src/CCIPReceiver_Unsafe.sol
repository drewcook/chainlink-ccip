/**
	Recxeiver of a CCIP Message from Avalanche Fuji to Ethereum Sepolia. The latest message sender and data will be readable as storage variables.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

contract CCIPReceiver_Unsafe is CCIPReceiver {
    address public lastSender;
    address public lassMessage;

    constructor(address _router) CCIPReceiver(_router) {}

    // Simply set the storage variables with the incoming CCIP Message data
    function _ccipReceive(
        Client.Any2EVMMessage memory _message
    ) internal override {
        lastSender = abi.decode(_message.sender, (address));
        lassMessage = abi.decode(_message.data, (address));
    }
}
