# Foundry Helpers

format:; forge fmt
clean:; forge clean
compile:; forge compile
build:; forge build
test:; forge test
snapshot:; forge snapshot

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Unsafe Message Sender

deployFujiSenderUnsafe:; forge script ./script/DeployCCIPSender_Unsafe.s.sol:DeployCCIPSender_Unsafe --rpc-url avalancheFuji --broadcast --verify $ETHERSCAN_API_KEY -vvv
deploySepoliaReceiverUnsafe:; forge script ./script/DeployCCIPReceiver_Unsafe.s.sol:DeployCCIPReceiver_Unsafe --rpc-url ethereumSepolia --broadcast --verify $ETHERSCAN_API_KEY -vvv
sendFujiMessageToSeploliaUnsafe:; forge script ./script/interactions/SendMessage_Unsafe.s.sol:SendMessage_Unsafe --rpc-url avalancheFuji --broadcast -vvv

# CCIP-BnM Token Sender

deployFujiTokenSender:; forge script ./script/DeployCCIPTokenSender.s.sol:DeployCCIPTokenSender --rpc-url avalancheFuji --broadcast -vvv
sendFujiTokenToSepolia:; forge script ./script/interactions/SendToken.s.sol:SendCCIPBnMToken --rpc-url avalancheFuji --broadcast -vvv

# Token and Data Sender

deployFujiTokenAndDataSender:; forge script ./script/DeployCCIPTokenAndDataSender.s.sol:DeployCCIPTokenAndDataSender --rpc-url avalancheFuji --broadcast --verify $ETHERSCAN_API_KEY -vvv
deploySepoliaTokenAndDataReceiver:; forge script ./script/DeployCCIPTokenAndDataReceiver.s.sol:DeployCCIPTokenAndDataReceiver --rpc-url ethereumSepolia --broadcast --verify $ETHERSCAN_API_KEY -vvv
whitelistSenderAndFujiAsSourceChain:; forge script ./script/interactions/SendTokenAndData.s.sol:WhitelistSenderAndFujiAsSourceChain --rpc-url ethereumSepolia --broadcast -vvv
whitelistSepoliaAsDestinationChain:; forge script ./script/interactions/SendTokenAndData.s.sol:WhitelistSepoliaAsDestinationChain --rpc-url avalancheFuji --broadcast -vvv
mintNFTOnSepoliaAndPayForItOnFuji:; forge script ./script/interactions/SendTokenAndData.s.sol:MintNFTOnSepoliaAndPayForItOnFuji --rpc-url avalancheFuji --broadcast -vvv
