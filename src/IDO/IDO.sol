// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract IDO {
    address immutable erc20_ca;
    uint256 public deadline;
    uint256 public price;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public totalSupplyLimit;
    uint256 public minimumAmount;

    uint256 public totalRaisingAmount;
    mapping(address => uint) raisingAmount;
    mapping(address => bool) claimedOrWithdrawed;

    event PreBought(address buyer, uint256 amount);
    event WithDrawed(address source, uint256 amount);
    event Claimed(address source, uint256 amount);

    constructor(
        address _erc20_ca,
        uint256 _deadline,
        uint256 _price,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _totalSupplyLimit,
        uint256 _minimumAmount
    ) {
        erc20_ca = _erc20_ca;
        deadline = _deadline;
        price = _price;
        softCap = _softCap;
        hardCap = _hardCap;
        totalSupplyLimit = _totalSupplyLimit;
        minimumAmount = _minimumAmount;
    }

    receive() external payable {
        revert("direct transfer not support");
    }

    function preBuy() external payable {
        require(msg.value + totalRaisingAmount <= hardCap, "exceed hard cap");
        require(msg.value >= minimumAmount, "minimum amount not meet");
        require(block.timestamp <= deadline, "exceed deadline");
        totalRaisingAmount += msg.value;
        raisingAmount[msg.sender] += msg.value;
        emit PreBought(msg.sender, msg.value);
    }

    function withdraw() external {
        require(block.timestamp > deadline, "too early to withDraw");
        require(totalRaisingAmount < softCap, "foundraising succeed");
        require(
            claimedOrWithdrawed[msg.sender] == false,
            "you have withdrawed"
        );
        claimedOrWithdrawed[msg.sender] = true;
        uint256 withdrawed = raisingAmount[msg.sender];
        (bool succeed, ) = msg.sender.call{value: withdrawed}(
            ""
        );
        require(succeed, "failed to send ether");
        emit WithDrawed(msg.sender, withdrawed);
    }

    function claim() external {
        require(block.timestamp > deadline, "too early to withDraw");
        require(totalRaisingAmount > softCap, "foundraising didn't succeed");
        require(raisingAmount[msg.sender] > 0, "no token to claim");
        require(claimedOrWithdrawed[msg.sender] == false, "you have claimed");
        claimedOrWithdrawed[msg.sender] = true;
        uint256 claimed = (totalSupplyLimit / totalRaisingAmount) *
            raisingAmount[msg.sender];
        IERC20(erc20_ca).transfer(msg.sender, claimed);
        emit Claimed(msg.sender, claimed);
    }
}
