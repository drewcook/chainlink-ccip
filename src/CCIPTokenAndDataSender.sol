/**
 * Mint an NFT on one chain and pay for minting on another, from Avalanche Fuji to Ethereum Sepolia via a burn/mint mechanism. To mint an NFT on the destination chain, we will send the minting price amount of tokens & ABI encoded NFT contract's mint function signature as a data parameter of the CCIP Message. The CCIP fees will be paid in LINK token.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract CCIPTokenAndDataSender is OwnerIsCreator {
    IRouterClient router;
    LinkTokenInterface link;

    mapping(uint64 => bool) public whitelistedChains;

    error CCIPTokenSender__NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
    error CCIPTokenSender__DestinationChainNotWhitelisted(uint64 destinationChainSelector);
    error NothingToWithdraw();

    // The chain selector of the destination chain.
    // The address of the receiver on the destination chain.
    // The token address that was transferred.
    // The token amount that was transferred.
    // the token address used to pay CCIP fees.
    // The fees paid for sending the message.
    // The unique ID of the message.
    event TokensTransferred(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        address token,
        uint256 tokenAmount,
        address feeToken,
        uint256 fees
    );

    modifier onlyWhitelistedDestinations(uint64 _destinationChainSelector) {
        if (!whitelistedChains[_destinationChainSelector]) {
            revert CCIPTokenSender__DestinationChainNotWhitelisted(_destinationChainSelector);
        }
        _;
    }

    constructor(address _link, address _router) {
        link = LinkTokenInterface(_link);
        router = IRouterClient(_router);
    }

    function whitelistDestinationChain(uint64 _destinationChainSelector) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = true;
    }

    function denyDestinationChain(uint64 _destinationChainSelector) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = false;
    }

    // Transfers the given token of a given amount to the receiver on the destination chain
    // Only the owner of the contract can send, and the destination chaains are whitelisted
    function transferTokens(uint64 _destinationChainSelector, address _token, address _receiver, uint256 _amount)
        external
        onlyOwner
        onlyWhitelistedDestinations(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        // Create the token amounts being transferred, in this case only one type of token
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({token: _token, amount: _amount});
        tokenAmounts[0] = tokenAmount;

        // Encode the minting function signature to use as the data parameter for the CCIP Message
        bytes memory mintCalldata = abi.encodeWithSignature("mintToken(address)", msg.sender);

        // Create the CCIP Message
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: mintCalldata, // we expect this to send to an EOA
            tokenAmounts: tokenAmounts,
            feeToken: address(link),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // these are the defaults, but we want to explicitly set gas to a level that will be able to cover the costs for the mint function
            )
        });

        // CCIP Fees management - only approve the Router.sol to spend the fees for the given token (which is LINK in this case)
        uint256 fees = router.getFee(_destinationChainSelector, message);
        if (fees > link.balanceOf(address(this))) {
            revert CCIPTokenSender__NotEnoughBalance(link.balanceOf(address(this)), fees);
        }
        link.approve(address(router), fees);

        // Approve the Router to spend the amount of the custom token being transferred (CCIP-BnM)
        IERC20(_token).approve(address(router), _amount);

        // Send the CCIP Message
        messageId = router.ccipSend(_destinationChainSelector, message);

        // Emit our custom event
        emit TokensTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, address(link), fees);
    }

    function withdraw(address _beneficiary, address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        if (amount == 0) {
            revert NothingToWithdraw();
        }

        IERC20(_token).transfer(_beneficiary, amount);
    }
}
