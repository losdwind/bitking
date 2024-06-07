pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "./Staking.sol";

contract StakingTest is Test {
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    address staking_ca;
    address rnt_ca;
    address esRNT_ca;
    address alice;

    event Staked(address indexed staker, uint256 amount);
    event Minted(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event ForceWithdrawn(address indexed to, uint256 amount);

    function setUp() public {
        rnt_ca = address(new RNT());
        esRNT_ca = address(new esRNT(rnt_ca));
        staking_ca = address(new Staking(rnt_ca, esRNT_ca));
        alice = makeAddr("alice");
        RNT(rnt_ca).transfer(alice, 1 ether);
        RNT(rnt_ca).transfer(staking_ca, 90 ether);
    }

    function test_staking() public {
        vm.startPrank(alice);
        RNT(rnt_ca).approve(staking_ca, 1 ether);

        // stake 1 ether
        vm.expectEmit();
        emit Staked(alice, 1 ether);
        Staking(staking_ca).stake(1 ether);
        vm.stopPrank();
    }

    function test_unstaking() public {
        vm.startPrank(alice);
        RNT(rnt_ca).approve(staking_ca, 1 ether);
        vm.warp(1);
        Staking(staking_ca).stake(1 ether);
        vm.assertEq(RNT(rnt_ca).balanceOf(alice), 0 ether);

        // unstake after 10 days
        vm.warp(1 + 10 days);
        Staking(staking_ca).unstake(1 ether);

        vm.assertEq(RNT(rnt_ca).balanceOf(alice), 1 ether);

        vm.stopPrank();
    }

    function test_claim() public {
        vm.startPrank(alice);
        RNT(rnt_ca).approve(staking_ca, 1 ether);
        vm.warp(1);
        Staking(staking_ca).stake(1 ether);
        vm.warp(1 + 10 days);

        // claim
        Staking(staking_ca).claim();

        // claim result
        (uint256 amount, uint256 unlockTime) = esRNT(esRNT_ca).locks(alice, 0);

        assertEq(amount, 10 ether);
        assertEq(unlockTime, block.timestamp);
    }

    function test_withdraw() public {
        vm.startPrank(alice);
        RNT(rnt_ca).approve(staking_ca, 100 ether);
        Staking(staking_ca).stake(1 ether);
        vm.warp(block.timestamp + 10 days);
        Staking(staking_ca).claim();
        (uint256 amount, uint256 unlockTime) = esRNT(esRNT_ca).locks(alice, 0);

        // withdraw will fail with reason "No esRNT has unlocked"
        vm.expectRevert("No esRNT has unlocked");
        esRNT(esRNT_ca).withdraw();

        // withdraw success with 10 ether RNT
        vm.warp(block.timestamp + 31 days);
        vm.expectEmit();
        emit Withdrawn(alice, 10 ether);
        esRNT(esRNT_ca).withdraw();
    }

    function test_forceWithdraw() public {
        vm.startPrank(alice);
        RNT(rnt_ca).approve(staking_ca, 100 ether);
        Staking(staking_ca).stake(1 ether);
        vm.warp(block.timestamp + 20 days);
        Staking(staking_ca).claim();

        // early force withdraw in the 20th days
        vm.expectEmit();
        emit ForceWithdrawn(alice, 4 ether); // 20 * 20%
        esRNT(esRNT_ca).forceWithdraw();
    }
}
