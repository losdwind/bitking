// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/EIP2612/NewNft.sol";
import "../../src/UpgradableNftMarket/NftMarketV1.sol";
import "../../src/UpgradableNftMarket/NftMarketV2.sol";
import "../../src/EIP2612/NewToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NftMarketV2Test is Test {
    address nftAddress;
    address tokenAddress;
    address uupsProxy;

    address alice;
    address bob;

    event Listed(address from, uint price);

    function setUp() public {
        alice = vm.addr(1);
        bob = makeAddr("bob"); 

        // prepare alice's nft balance and bob's token balance
        nftAddress = address(new NewNft(11155111));
        tokenAddress = address(new NewToken("AJ Coin", "AJC", 11155111));
        vm.prank(alice);
        NewNft(nftAddress).mint();
        NewToken(tokenAddress).transfer(bob, 1 ether);


        // deploy the nftmarket proxy and implementation
        uupsProxy = Upgrades.deployUUPSProxy(
            "NftMarketV1.sol",
            abi.encodeCall(
                NftMarketV1.initialize,
                (tokenAddress, nftAddress, address(this))
            )
        );
    }

    function test_upgradeToV2() public {
        NftMarketV1 instance = NftMarketV1(uupsProxy);
        vm.prank(alice);
        NewNft(nftAddress).approve(address(instance), 0);
        vm.prank(alice);
        instance.list(0, 1 ether);
        vm.prank(bob);
        NewToken(tokenAddress).approve(address(instance), 1 ether);
        vm.prank(bob);
        instance.buyNFT(0);

        // bob bought alice's #0 NFT
        vm.assertEq(NewToken(tokenAddress).balanceOf(alice), 1 ether);
        vm.assertEq(NewNft(nftAddress).ownerOf(0), bob);

        // upgrade to V2
        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");

        NftMarketV2 instance2 = NftMarketV2(uupsProxy);
        vm.prank(bob);
        NewNft(nftAddress).approve(address(instance2), 0);
        vm.prank(bob);
        instance.list(0, 1 ether);
        vm.prank(alice);
        NewToken(tokenAddress).approve(address(instance2), 1 ether);
        vm.prank(alice);
        instance.buyNFT(0);

        // alice bought bob's #0 NFT
        vm.assertEq(NewToken(tokenAddress).balanceOf(bob), 1 ether);
        vm.assertEq(NewNft(nftAddress).ownerOf(0), alice);

    }

}
