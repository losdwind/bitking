pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "./KKStakingPool.sol";

contract KKStakingTest is Test {
    struct Stake {
        uint128 amount;
        uint128 lastUpdatedCumulatedAverage;
        uint128 cumulatedKKToken;
    }

    struct TotalStakeAverage {
        uint128 totalStake;
        uint128 lastUpdatedBlockNumber;
        uint128 lastUpdatedCumulatedAverage;
    }

    address staking_ca;
    address kk_ca;
    address alice;

    event Staked(address indexed staker, uint128 amount);
    event Minted(address indexed to, uint128 amount);
    event Withdrawn(address indexed to, uint128 amount);
    event ForceWithdrawn(address indexed to, uint128 amount);

    function setUp() public {
        kk_ca = address(new KKToken());
        staking_ca = address(new KKStakingPool(kk_ca));
        alice = makeAddr("alice");
        KKToken(kk_ca).transfer(staking_ca, 1000 ether);
    }

    function test_fuzz_staking(uint128 amount) public {
        vm.assume(amount > 0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        // stake 1 ether
        vm.expectEmit();
        emit Staked(alice, amount);
        KKStakingPool(payable(staking_ca)).stake{value: amount}();
        vm.stopPrank();
    }

    function test_fuzz_unstaking(uint128 amount, uint256 roll) public {
        vm.assume(amount > 0);
        vm.assume(roll < 100 && roll > 0);
        vm.roll(0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        KKStakingPool(payable(staking_ca)).stake{value: amount}();
        assertEq(alice.balance, 0);

        vm.roll(roll);
        KKStakingPool(payable(staking_ca)).unstake(amount);
        console.log("alice's balance", alice.balance);
        assertEq(alice.balance, amount);

        vm.stopPrank();
    }

    function test_fuzz_claim(uint128 amount, uint256 roll) public {
        vm.assume(amount > 0);
        vm.assume(amount < 1000000 ether); // restrict staking amount to prevent overflow
        vm.assume(roll < 100 && roll > 0);
        vm.roll(0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        KKToken(kk_ca).approve(staking_ca, amount);
        KKStakingPool(payable(staking_ca)).stake{value: amount}();

        vm.roll(roll);
        KKStakingPool(payable(staking_ca)).claim();
        console.log("difference", roll * 10 ether - KKToken(kk_ca).balanceOf(alice));
        assertLe(roll * 10 ether -  KKToken(kk_ca).balanceOf(alice), 1 ether); // 1 ether difference occured when allocate a lot of ethers with large roll
    }
}
