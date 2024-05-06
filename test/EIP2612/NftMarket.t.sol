// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/EIP2612/NewNft.sol";
import "../../src/EIP2612/NewNftMarket.sol";
import "../../src/EIP2612/NewToken.sol";

contract NftMarketTestV1 is Test {
    address nftAddress;
    address nftMarketAddress;
    address tokenAddress;

    function setUp() public {
        nftAddress = address(new NewNft(11155111));
        tokenAddress = address(new NewToken("AJ Coin", "AJC", 11155111));
        nftMarketAddress = address(new NftMarket(tokenAddress, nftAddress));
    }

    function test_permitBuy() public {
        uint alicePrivateKey = 1;
        uint bobPrivateKey = 2;
        address alice = vm.addr(alicePrivateKey);
        address bob = vm.addr(bobPrivateKey);

        // alice mint a nft
        vm.prank(alice);
        NewNft(nftAddress).mint();
        // bob get the money to buy nft
        NewToken(tokenAddress).transfer(bob, 1e18);

        console.log("Alice has minted a NFT with ID:", NewNft(nftAddress).tokenId() - 1);
        console.log("Alice has token balance of", NewToken(tokenAddress).balanceOf(alice));

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
                        nftMarketAddress,
                        0,
                        1e18,
                        0,
                        timestamp + 2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        console.log("Alice generated the signature for digest");
        // bob approve
        vm.prank(bob);
        NewToken(tokenAddress).approve(nftMarketAddress, 1e18);
        // console.log(
        //     "allowance from bob to nft market",
        //     NewToken(tokenAddress).allowance(bob, nftMarketAddress)
        // );

        console.log("Bob's NFT balance is ", NewNft(nftAddress).balanceOf(bob));
        console.log("Bob has token balance of", NewToken(tokenAddress).balanceOf(bob));

        console.log("Bob using Alice's signature to buy the NFT....");
        // bob get the signature and try permitBuy
        vm.prank(bob);
        NftMarket(nftMarketAddress).permitBuy(
            alice,
            nftMarketAddress,
            0,
            1e18,
            0,
            timestamp + 2 days,
            v,
            r,
            s
        );

        vm.assertEq(NewNft(nftAddress).ownerOf(0), bob);

        console.log("Alice has balance of NFT:", NewNft(nftAddress).balanceOf(alice));
        console.log("Alice has token balance of", NewToken(tokenAddress).balanceOf(alice));
        console.log("Bob has balance of NFT:", NewNft(nftAddress).balanceOf(bob));
        console.log("Bob has token balance of", NewToken(tokenAddress).balanceOf(bob));
    }

    function testFailed_directBuy() external {
        uint alicePrivateKey = 1;
        uint bobPrivateKey = 2;
        address alice = vm.addr(alicePrivateKey);
        address bob = vm.addr(bobPrivateKey);

        // alice mint a nft
        vm.prank(alice);
        NewNft(nftAddress).mint();

        // bob get the money to buy nft
        NewToken(tokenAddress).transfer(bob, 1e18);

        // bob approve
        vm.prank(bob);
        NewToken(tokenAddress).approve(nftMarketAddress, 1e18);
        
        // bob use fake signature to buy nft, expect to fail
        vm.prank(bob);
        NftMarket(nftMarketAddress).permitBuy(
            alice,
            nftMarketAddress,
            0,
            1e18,
            0,
            block.timestamp + 2 days,
            0,
            bytes32("0xad231"),
            bytes32("0x2731")
        );
    }
}
