// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../../src/nft-basic/10_NFT_Market_Extended.sol";
import "../../src/nft-basic/9_ERC721.sol";
import "../../src/nft-basic/8_ERC_20_Extended.sol";

contract NftMarketTest is Test {
    AJNFT nft;
    BaseERC20 coin;
    NftMarket market;
    address alice;
    address bob;

    event Listed(address seller, uint price);
    event Sold(address seller, address buyer, uint price);

    function setUp() public {
        coin = new BaseERC20();
        nft = new AJNFT();
        market = new NftMarket(address(coin), address(nft));
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.prank(alice);
        nft.mint();
        vm.prank(bob);
        nft.mint();

        coin.transfer(alice, 3 ether);
        coin.transfer(bob, 4 ether);
    }

    function test_setUp() public {
        assertEq(nft.balanceOf(alice), 1);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(coin.balanceOf(alice), 3 ether);
        assertEq(coin.balanceOf(bob), 4 ether);

        assert(nft.ownerOf(1) == alice);
        assert(nft.ownerOf(2) == bob);
    }

    function test_listNft() public {
        console.log("alice: %s", alice);
        console.log("bob: %s", bob);
        console.log("market: %s", address(market));
        vm.prank(alice);
        nft.approve(address(market), 1);
        assertEq(nft.getApproved(1), address(market));
        vm.prank(bob);
        coin.approve(address(market), 3e18);
        assertEq(coin.allowance(bob, address(market)), 3 ether);
        vm.prank(alice);
        market.list(1, 3 ether);

        // assertEq(nft.getApproved(1), address(market));
        assertEq(nft.ownerOf(1), address(market));
    }

    function test_buyNft() public {
        console.log("alice: %s", alice);
        console.log("bob: %s", bob);
        vm.prank(alice);
        nft.approve(address(market), 1);
        assertEq(nft.getApproved(1), address(market));
        vm.prank(bob);
        coin.approve(address(market), 3e18);
        assertEq(coin.allowance(bob, address(market)), 3 ether);
        vm.prank(alice);
        market.list(1, 3 ether);
        vm.prank(bob);
        market.buyNFT(1);

        assertEq(nft.balanceOf(bob), 2);
        assertEq(nft.balanceOf(alice), 0);
        assertEq(coin.balanceOf(bob), 4 ether - 3 ether);
        assertEq(coin.balanceOf(alice), 3 ether + 3 ether);
    }

    function test_buyNftCallback() public {
        console.log("alice: %s", alice);
        console.log("bob: %s", bob);
        vm.prank(alice);
        nft.approve(address(market), 1);
        assertEq(nft.getApproved(1), address(market));
        vm.prank(bob);
        coin.approve(address(market), 3e18);
        assertEq(coin.allowance(bob, address(market)), 3 ether);
        vm.prank(alice);
        market.list(1, 3 ether);
        vm.prank(bob);
        coin.transferWithCallback(address(market), 3 ether, abi.encode(1)); // bob transfer 3 ether to market;

        assertEq(nft.balanceOf(bob), 2);
        assertEq(nft.balanceOf(alice), 0);
        assertEq(coin.balanceOf(bob), 4 ether - 3 ether);
        assertEq(coin.balanceOf(alice), 3 ether + 3 ether);
    }

    function test_listEvent() public {
        vm.prank(alice);
        nft.approve(address(market), 1);
        assertEq(nft.getApproved(1), address(market));
        vm.prank(bob);
        coin.approve(address(market), 3e18);
        assertEq(coin.allowance(bob, address(market)), 3 ether);
        vm.prank(alice);

        vm.expectEmit();
        emit Listed(alice, 3e18);
        market.list(1, 3 ether);
    }

    function test_soldEvent() public {
        vm.prank(alice);
        nft.approve(address(market), 1);
        assertEq(nft.getApproved(1), address(market));
        vm.prank(bob);
        coin.approve(address(market), 3e18);
        assertEq(coin.allowance(bob, address(market)), 3 ether);
        vm.prank(alice);
        market.list(1, 3 ether);
        vm.prank(bob);

        vm.expectEmit();
        emit Sold(alice, bob, 3e18);
        coin.transferWithCallback(address(market), 3 ether, abi.encode(1)); // bob transfer 3 ether to market;
    }
}
