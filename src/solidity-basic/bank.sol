// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[3] public topDepositors;

    event Withdrawed(address from, address to, uint256 amount);

    constructor() {
        owner = msg.sender;
        topDepositors = [address(0), address(0), address(0)];
    }

    // 接收存款的回退函数
    receive() external payable virtual {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, balances[msg.sender]);
    }

    // 更新前三存款者的记录
    function updateTopDepositors(address depositor, uint256 balance) internal {
        if (balance > balances[topDepositors[2]]) {
            if (balance > balances[topDepositors[1]]) {
                if (balance > balances[topDepositors[0]]) {
                    topDepositors[2] = topDepositors[1];
                    topDepositors[1] = topDepositors[0];
                    topDepositors[0] = depositor;
                    return;
                }
                topDepositors[2] = topDepositors[1];
                topDepositors[1] = depositor;
                return;
            }
            topDepositors[2] = depositor;
        }
    }

    // 提现方法，仅管理员可用
    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(address(this).balance >= amount, "Insufficient funds");

        payable(owner).transfer(amount);

        emit Withdrawed(address(this), msg.sender, amount);
    }

    // 查看前三名存款者的函数
    function getTopDepositors() public view returns (address[3] memory, uint256[] memory) {
        uint256[] memory topBalances = new uint256[](3);
        for (uint256 i = 0; i < topDepositors.length; i++) {
            if (topDepositors[i] != address(0)) {
                topBalances[i] = balances[topDepositors[i]];
            }
        }
        return (topDepositors, topBalances);
    }

    // 获取合约余额的函数
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
