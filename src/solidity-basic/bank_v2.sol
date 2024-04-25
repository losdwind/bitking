// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[] topThree;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        updateTopThree(msg.sender);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    function getTopThree() external view returns (address[] memory) {
        return topThree;
    }

    function updateTopThree(address depositor) internal {
        if (topThree.length < 3) {
            topThree.push(depositor);
        } else {
            uint256 minBalance = balances[topThree[0]];
            uint256 minIndex = 0;
            for (uint256 i = 1; i < topThree.length; i++) {
                if (balances[topThree[i]] < minBalance) {
                    minBalance = balances[topThree[i]];
                    minIndex = i;
                }
            }
            if (balances[depositor] > minBalance) {
                topThree[minIndex] = depositor;
            }
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
