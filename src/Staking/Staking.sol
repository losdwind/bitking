// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking {
    struct Stake {
        uint amount;
        uint lastUpdate;
        uint waitToClaim;
    }

    address rnt_ca;
    address es_rnt_ca;

    mapping(address => Stake) stakeRecords;

    event Staked(address staker, Stake record);
    event Withdrawed(address staker, Stake record);
    event Claimed(address staker, Stake record);

    constructor(address _rnt_ca, address _es_rnt_ca) {
        rnt_ca = _rnt_ca;
        es_rnt_ca = _es_rnt_ca;
    }

    function stake(uint256 amount) external {
        IERC20(rnt_ca).transferFrom(msg.sender, address(this), amount);
        Stake memory record = stakeRecords[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        record.waitToClaim +=
            ((currentTimestamp - record.lastUpdate) / 1 days) *
            record.amount;
        record.lastUpdate = currentTimestamp;
        record.amount += amount;
        emit Staked(msg.sender, record);
    }

    // withdraw RNT
    function withDraw(uint256 amount) external {
        Stake memory record = stakeRecords[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        record.waitToClaim +=
            ((currentTimestamp - record.lastUpdate) / 1 days) *
            record.amount;
        record.lastUpdate = currentTimestamp;
        record.amount -= amount;
        RNT(rnt_ca).transfer(msg.sender, amount);
        emit Withdrawed(msg.sender, record);
    }

    // claim esRNT
    function claim() external {
        Stake memory record = stakeRecords[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        record.waitToClaim +=
            ((currentTimestamp - record.lastUpdate) / 1 days) *
            record.amount;
        record.lastUpdate = currentTimestamp;
        uint claim_ = record.waitToClaim;
        record.waitToClaim = 0;
        RNT(rnt_ca).transfer(es_rnt_ca, claim_);
        esRNT(es_rnt_ca).mint(msg.sender, claim_);
    }

    function exchange() external {}
}

contract RNT is ERC20 {
    constructor() ERC20("RNT", "RNT") {
        _mint(msg.sender, 100 ether);
    }
}

contract esRNT is ERC20 {
    struct Lock {
        uint256 locked;
        uint256 unlockTime;
        uint256 unlocked;
    }

    constructor() ERC20("esRNT", "esRNT") {
        _mint(msg.sender, 100 ether);
    }

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }

    function withdraw() external {
        // 80% burn
    }
}
