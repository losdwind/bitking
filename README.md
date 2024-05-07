## Upgradable NFT Market
![screenshot of tests](<test-screenshot.png>)
### Deploy

```bash
forge clean && forge script --sender 0x22271C6e574f36149907eb7753C07d0bEA7Ba98c --rpc-url sepolia --account os ./script/NftMarketUpgradable.s.sol:NftMarketUpgradableScript --broadcast --etherscan-api-key sepolia --verify
```

### Verified Contract

- Proxy Contract: [0x89BD1F4b94afA6aF9420B6112FF67DA643CC5bE9](https://sepolia.etherscan.io/address/0x89bd1f4b94afa6af9420b6112ff67da643cc5be9)
- NFT market V2 Implementation Contract: [0xda594A4B47826C0807d3D583737dA825A97818C1](https://sepolia.etherscan.io/address/0xda594a4b47826c0807d3d583737da825a97818c1)
- NFT Market V1 Implementation Contract: [0xf6da22e980ac2dfd9181a90baba2b89d8ef7e76e](https://sepolia.etherscan.io/address/0xf6da22e980ac2dfd9181a90baba2b89d8ef7e76e)
- NFT Contract: [0x3a150E29ce13de7b009BA28DFd6EC81b1565EF3b](https://sepolia.etherscan.io/address/0x3a150e29ce13de7b009ba28dfd6ec81b1565ef3b)
- Token Contract: [0x567357311D92395e22Ff9775265Ed89cb1317dAd](https://sepolia.etherscan.io/address/0x567357311d92395e22ff9775265ed89cb1317dad)

### Manual

- [openzeppelin-foundry-upgrades](https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades)
- [How to Create and Deploy an Upgradeable ERC20 Token](https://www.quicknode.com/guides/ethereum-development/smart-contracts/how-to-create-and-deploy-an-upgradeable-erc20-token#create-the-erc-20-upgradeable-token-smart-contract)

