pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "./KKStakingPool.sol";

contract KKStakingTest is Test {
    struct Stake {
        uint256 amount;
        uint256 lastUpdatedCumulatedAverage;
        uint256 cumulatedKKToken;
    }

    struct TotalStakeAverage {
        uint256 totalStake;
        uint256 lastUpdatedBlockNumber;
        uint256 lastUpdatedCumulatedAverage;
    }

    address staking_ca;
    address kk_ca;
    address alice;

    event Staked(address indexed staker, uint256 amount);
    event Minted(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event ForceWithdrawn(address indexed to, uint256 amount);

    function setUp() public {
        kk_ca = address(new KKToken());
        staking_ca = address(new KKStakingPool(kk_ca));
        alice = makeAddr("alice");
        KKToken(kk_ca).transfer(staking_ca, 1000 ether);
    }

    function test_fuzz_staking(uint256 amount) public {
        vm.assume(amount > 0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        // stake 1 ether
        vm.expectEmit();
        emit Staked(alice, amount);
        KKStakingPool(payable(staking_ca)).stake{value: amount}();
        vm.stopPrank();
    }

    function test_fuzz_unstaking(uint256 amount, uint256 roll) public {
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

    function test_fuzz_claim(uint256 amount, uint256 roll) public {
        vm.assume(amount > 0);
        vm.assume(roll < 100 && roll > 0);
        vm.roll(0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        KKToken(kk_ca).approve(staking_ca, amount);
        KKStakingPool(payable(staking_ca)).stake{value: amount}();

        vm.roll(10);
        KKStakingPool(payable(staking_ca)).claim();
    }
}
