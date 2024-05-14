// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../../src/nft-basic/8_ERC_20_Extended.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test {
    BaseERC20 token;
    address alice;
    address bob;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        token = new BaseERC20();
    }

    function test_transfer(uint256 amount) public {
        vm.assume(amount < token.totalSupply());
        emit log_address(alice);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }

    function test_allowance(uint256 amount) public {
        vm.assume(amount < token.totalSupply());
        token.transfer(alice, amount);
        vm.prank(alice);
        token.approve(address(this), amount);
        assertEq(token.allowance(alice, address(this)), amount);
    }

    function test_transferFrom(uint256 amount) public {
        vm.assume(amount < token.totalSupply());
        token.transfer(alice, amount);
        vm.prank(alice);
        token.approve(address(this), amount);
        token.transferFrom(alice, bob, amount);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(alice), 0);
    }

    function test_transferFrom_withoutApprove(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < token.totalSupply());
        token.transfer(alice, amount);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(alice, bob, amount);
    }

    function test_transferFrom_emitTransfer() public {
        token.transfer(alice, 1e18);
        vm.prank(alice);
        token.approve(address(this), 1e18);
        vm.expectEmit();
        emit Transfer(alice, bob, 1e18);
        token.transferFrom(alice, bob, 1e18);
    }
}
