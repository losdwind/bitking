// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract KKStakingPool {
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

    address public immutable kk_ca;

    TotalStakeAverage totalAverage;
    mapping(address => Stake) public records;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event Claimed(address indexed staker, uint256 amount);

    constructor(address _kk_ca) {
        kk_ca = _kk_ca;
    }

    receive() external payable {

    }

    function stake() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 currentBlock = block.number;
        Stake storage record = records[msg.sender];

        // update total
        totalAverage.totalStake += msg.value;
        totalAverage.lastUpdatedCumulatedAverage +=
            10 ether * (currentBlock - totalAverage.lastUpdatedBlockNumber) / totalAverage.totalStake;
        totalAverage.lastUpdatedBlockNumber = block.number;

        // update user
        record.cumulatedKKToken += record.amount * (totalAverage.lastUpdatedCumulatedAverage - record.lastUpdatedCumulatedAverage);
        record.lastUpdatedCumulatedAverage = totalAverage.lastUpdatedCumulatedAverage;
        record.amount += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    /// @notice unstake to get back user's ETH
    /// @dev Explain to a developer any extra details
    /// @param amount the amount of ether user want to unstake)
    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        Stake storage record = records[msg.sender];
        require(record.amount >= amount, "Insufficient staked amount");
        uint256 currentBlock = block.number;
        require(currentBlock > totalAverage.lastUpdatedCumulatedAverage, "block does not change");
        // update total
        totalAverage.lastUpdatedCumulatedAverage +=
            10 ether * (currentBlock - totalAverage.lastUpdatedBlockNumber) / totalAverage.totalStake;

        totalAverage.totalStake -= amount;

        totalAverage.lastUpdatedBlockNumber = block.number;

        // update user
        record.cumulatedKKToken +=
            record.amount * (totalAverage.lastUpdatedCumulatedAverage - record.lastUpdatedCumulatedAverage);
        record.lastUpdatedCumulatedAverage = totalAverage.lastUpdatedCumulatedAverage;
        record.amount -= amount;
        console.log("balance of kkstakng pool", address(this).balance);
        (bool success,) = payable(msg.sender).call{value: amount}("");
        console.log("success", success);
        require(success, "Failed to send Ether");

        emit Unstaked(msg.sender, amount);
    }

    function claim() external {
        Stake storage record = records[msg.sender];
        require(record.amount > 0, "Nothing to claim");

        // update user
        record.cumulatedKKToken +=
            record.amount * (totalAverage.lastUpdatedCumulatedAverage - record.lastUpdatedCumulatedAverage);
        record.lastUpdatedCumulatedAverage = totalAverage.lastUpdatedCumulatedAverage;
        uint256 canClaim = record.cumulatedKKToken;
        record.cumulatedKKToken = 0;

        IERC20(kk_ca).transfer(msg.sender, canClaim);
        emit Claimed(msg.sender, canClaim);
    }

    function balanceOf(address account) external view returns (uint256) {
        return records[account].amount;
    }

    function earned(address account) external view returns (uint256) {
        Stake storage record = records[account];
        uint256 cumulatedKKToken = record.cumulatedKKToken
            + record.amount * (totalAverage.lastUpdatedCumulatedAverage - record.lastUpdatedCumulatedAverage);

        return cumulatedKKToken;
    }
}

contract KKToken is ERC20 {
    constructor() ERC20("KK Token", "KKT") {
        _mint(msg.sender, 10000 ether);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
