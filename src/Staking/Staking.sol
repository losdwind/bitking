// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "./../../lib/forge-std/src/console.sol";

contract Staking {
    struct Stake {
        uint256 amount;
        uint256 lastUpdate;
        uint256 waitToClaim;
    }

    address public immutable rnt_ca;
    address public immutable es_rnt_ca;

    mapping(address => Stake) public records;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event Claimed(address indexed staker, uint256 amount);

    constructor(address _rnt_ca, address _es_rnt_ca) {
        rnt_ca = _rnt_ca;
        es_rnt_ca = _es_rnt_ca;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(rnt_ca).transferFrom(msg.sender, address(this), amount);

        Stake storage record = records[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        if (record.amount > 0) {
            record.waitToClaim = record.waitToClaim += ((currentTimestamp - record.lastUpdate) / 1 days) * record.amount;
        }
        record.lastUpdate = currentTimestamp;
        record.amount += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        Stake storage record = records[msg.sender];
        require(record.amount >= amount, "Insufficient staked amount");

        uint256 currentTimestamp = block.timestamp;
        record.waitToClaim += ((currentTimestamp - record.lastUpdate) / 1 days) * record.amount;
        record.lastUpdate = currentTimestamp;
        record.amount -= amount;

        IERC20(rnt_ca).transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function claim() external {
        Stake storage record = records[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        record.waitToClaim += ((currentTimestamp - record.lastUpdate) / 1 days) * record.amount;
        record.lastUpdate = currentTimestamp;

        uint256 claimAmount = record.waitToClaim;
        require(claimAmount > 0, "Nothing to claim");
        record.waitToClaim = 0;

        IERC20(rnt_ca).transfer(es_rnt_ca, claimAmount);
        console.log("es_rnt_ca's rnt balance", IERC20(rnt_ca).balanceOf(es_rnt_ca));
        esRNT(es_rnt_ca).mint(msg.sender, claimAmount);

        emit Claimed(msg.sender, claimAmount);
    }
}

contract RNT is ERC20 {
    constructor() ERC20("RNT", "RNT") {
        _mint(msg.sender, 100 ether);
    }
}

contract esRNT is ERC20 {
    address public immutable rnt;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock[]) public locks;

    event Minted(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event ForceWithdrawn(address indexed to, uint256 amount);

    constructor(address _rnt) ERC20("esRNT", "esRNT") {
        rnt = _rnt;
    }

    fallback() external {
        revert();
    }

    function mint(address to, uint256 amount) external {
        // only staking contract can mint
        require(amount > 0, "Amount must be greater than 0");
        locks[to].push(Lock(amount, block.timestamp));
        emit Minted(to, amount);
    }

    function withdraw() external {
        Lock[] storage userLocks = locks[msg.sender];
        uint256 totalUnlockAmount = 0;
        uint256 currentTimestamp = block.timestamp;

        for (uint256 i = 0; i < userLocks.length; i++) {
            if (currentTimestamp > 30 days && userLocks[i].unlockTime <= currentTimestamp - 30 days) {
                totalUnlockAmount += userLocks[i].amount;
                console.log("totalUnlockAmount", totalUnlockAmount);
                userLocks[i].amount = 0;
            }
        }
        require(totalUnlockAmount > 0, "No esRNT has unlocked");
        IERC20(rnt).transfer(msg.sender, totalUnlockAmount);
        emit Withdrawn(msg.sender, totalUnlockAmount);
    }

    function forceWithdraw() external {
        Lock[] storage userLocks = locks[msg.sender];
        uint256 totalUnlockAmount = 0;

        for (uint256 i = 0; i < userLocks.length; i++) {
            totalUnlockAmount += userLocks[i].amount;
            console.log("totoal force unlock amount", totalUnlockAmount);
            userLocks[i].amount = 0;
        }
        delete(locks[msg.sender]);
        uint256 forceWithdrawAmount = totalUnlockAmount * 20 / 100; // 20% of total amount
        console.log("force with draw amount", forceWithdrawAmount);
        IERC20(rnt).transfer(msg.sender, forceWithdrawAmount);
        emit ForceWithdrawn(msg.sender, forceWithdrawAmount);
    }
}
