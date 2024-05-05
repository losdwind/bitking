// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/EIP2612/NewNft.sol";
import "../../src/EIP2612/NewNftMarket.sol";
import "../../src/EIP2612/NewToken.sol";

contract NftMarketTest is Test {
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

        // alice sign the permit
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NewNft(nftAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        nftMarketAddress,
                        0,
                        0,
                        2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        // bob approve
        vm.prank(bob);
        NewToken(tokenAddress).approve(nftMarketAddress, 1e18);
        console.log(
            "allowance from bob to nft market",
            NewToken(tokenAddress).allowance(bob, nftMarketAddress)
        );

        // bob get the signature and try permitBuy
        vm.prank(bob);
        NftMarket(nftMarketAddress).permitBuy(
            alice,
            nftMarketAddress,
            1e18,
            0,
            0,
            2 days,
            v,
            r,
            s
        );

        vm.assertEq(NewNft(nftAddress).ownerOf(0), bob);
    }
}
