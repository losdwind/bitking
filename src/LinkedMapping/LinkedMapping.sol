// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => address) topDepositors;

    address constant GUARD = address(1);

    event Withdrawed(address from, address to, uint256 amount);

    constructor() {
        owner = msg.sender;
        topDepositors[GUARD] = GUARD;
    }

    // 接收存款的回退函数
    receive() external payable virtual {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        updateTopDepositors(msg.sender, msg.value);
    }

    // function addDepositor(address prevDepositor, address currentRepositor) internal {
    //     address nextDepositor = topDepositors[topDepositors[prevDepositor]];
    //     topDepositors[prevDepositor] = currentDepositor;
    //     topDepositors[currentDepositor] = nextDepositor;
    // }

    function findPrevDepositor(uint256 balance) internal returns (address prevDepositor) {
        address iteratedDepositor = topDepositors[GUARD];

        while (iteratedDepositor != GUARD) {
            address nextDepositor = topDepositors[iteratedDepositor];
            if (balances[iteratedDepositor] >= balance && balances[nextDepositor] <= balance) {
                prevDepositor = iteratedDepositor;
            } else {
                iteratedDepositor = topDepositors[iteratedDepositor];
            }
        }
    }

    function verifyDepositor(address prevDepositor, address currentDepositor) internal returns (bool) {
        // address prevDepositorBalance = balances[prevDepositor];
        // address currentDepositorBalance = balances[currentDepositor];
        // address nextDepositBalance = balances[topDepositors[currentDepositor]];
        // if (prevDepositorBalance > currentDepositorBalance && currentDepositorBalance > nextDepositBalance) {
        //     return true;
        // } else {
        //     return false;
        // }
    }

    function removeDepositor(address prevDepositor) internal {}

    // 更新前三存款者的记录
    function updateTopDepositors(address depositor, uint256 amount) internal {
        // if (topDepositors[depositor] != address(0)) {
        //     findPrevDepositor(balances[depositor]);
        //     bool ok = verifyDepositor(depositor);
        //     if (!ok) {
        //         address newPrevDepositor = findPrevDepositor(depositor);
        //         // address oldPrevDepositor =
        //     }
        // }
    }

    // 提现方法，仅管理员可用
    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(address(this).balance >= amount, "Insufficient funds");

        payable(owner).transfer(amount);

        emit Withdrawed(address(this), msg.sender, amount);
    }

    // 查看前十名存款者的函数
    function getTopDepositors() public view returns (address[3] memory, uint256[] memory) {
        for (uint256 i = 0; i < 10; i++) {}
        // return (topDepositors, topBalances);
    }

    // 获取合约余额的函数
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
