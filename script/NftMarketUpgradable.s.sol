// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "forge-std/Script.sol";
import "../src/EIP2612/NewNft.sol";
import "../src/UpgradableNftMarket/NftMarketV1.sol";
import "../src/UpgradableNftMarket/NftMarketV2.sol";
import "../src/EIP2612/NewToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
contract NftMarketUpgradableScript is Script {

    function run() public {
        vm.startBroadcast();
        address nftAddress = address(new NewNft(11155111));
        address tokenAddress = address(new NewToken("AJ Coin", "AJC", 11155111));

        address uupsProxy = Upgrades.deployUUPSProxy(
            "NftMarketV1.sol",
            abi.encodeCall(
                NftMarketV1.initialize,
                (tokenAddress, nftAddress, address(this))
            )
        );
         // upgrade to V2
        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");
    }
}