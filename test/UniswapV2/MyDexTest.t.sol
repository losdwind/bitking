// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import {UniswapV2Router02} from "./../src/Periphery/UniswapV2Router02.sol";
import {UniswapV2Factory} from "./../src/Core/UniswapV2Factory.sol";
import "../src/Periphery/test/WETH9.sol";
import "../src/RNT.sol";
import "../src/MyDex.sol";

contract MyDexTest is Test {
    address router;
    address factory;
    address pair;
    address rnt;
    address weth;
    address admin;
    address alice;
    address bob;
    address myDex;

    function setUp() public {
        admin = makeAddr("admin");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.deal(admin, 1000 ether);
        vm.startPrank(admin);
        factory = address(new UniswapV2Factory(admin));
        weth = address(new WETH9()); // weth = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
        rnt = address(new RNT(20000000 ether));
        router = address(new UniswapV2Router02(factory, weth));
        myDex = address(new MyDex(router, rnt, pair));
        RNT(rnt).approve(myDex, 2000000 ether);
        RNT(rnt).transfer(myDex, 2000000 ether);
        MyDex(myDex).addLiquidityETH{value: 100 ether}(
            rnt, 200000 ether, 200000 ether, 100 ether, admin, block.timestamp + 1 days
        );
        vm.stopPrank();
    }

    function test_sellETH() public {
        vm.deal(alice, 1000 ether);
        vm.prank(alice);
        MyDex(myDex).sellETH{value: 1 ether}(rnt, 1900 ether);
        // assertTrue();
    }

    function test_buyETH() public {
        vm.prank(alice);
        RNT(rnt).approve(myDex, 2000 ether);
        MyDex(myDex).buyETH(alice, rnt, 2000 ether, 9.87 * 10 **17);
    }
}
