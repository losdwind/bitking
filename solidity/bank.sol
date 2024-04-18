// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping(address => uint) public balances;
    address[] public topDepositors;

    constructor() {
        owner = msg.sender;
        topDepositors = new address ;
    }

    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, balances[msg.sender]);
    }

    function updateTopDepositors(address depositor, uint amount) private {
        // Simple insertion sort
        for (uint i = 0; i < topDepositors.length; i++) {
            if (topDepositors[i] == address(0) || balances[topDepositors[i]] < amount) {
                // Shift addresses down
                for (uint j = topDepositors.length - 1; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = depositor;
                break;
            }
        }
    }

    function withdraw(uint amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(address(this).balance >= amount, "Insufficient funds");

        payable(owner).transfer(amount);
    }

    function getTopDepositors() public view returns (address[] memory, uint[] memory) {
        uint[] memory topBalances = new uint[](3);
        for (uint i = 0; i < topDepositors.length; i++) {
            if (topDepositors[i] != address(0)) {
                topBalances[i] = balances[topDepositors[i]];
            }
        }
        return (topDepositors, topBalances);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
