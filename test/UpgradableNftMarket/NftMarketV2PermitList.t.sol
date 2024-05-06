// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/EIP2612/NewNft.sol";
import "../../src/UpgradableNftMarket/NftMarketV1.sol";
import "../../src/UpgradableNftMarket/NftMarketV2.sol";
import "../../src/EIP2612/NewToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NftMarketV2PermitListTest is Test {
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

        // upgrade to V2
        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");
    }

    function test_permitList() public{

        console.log(
            "Alice has minted a NFT with ID:",
            NewNft(nftAddress).tokenId() - 1
        );
        console.log(
            "Alice has token balance of",
            NewToken(tokenAddress).balanceOf(alice)
        );

        uint timestamp = block.timestamp;

        // alice sign the permit
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NewNft(nftAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint price,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        uupsProxy,
                        0,
                        1e18,
                        0,
                        timestamp + 2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        console.log("Alice generated the signature for digest");

        vm.expectEmit();
        emit Listed(alice, 1e18);
        NftMarketV2(uupsProxy).permitList(
            alice,
            uupsProxy,
            0,
            1e18,
            0,
            timestamp + 2 days,
            v,
            r,
            s
        );
    }
}
