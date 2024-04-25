// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./bank.sol";

contract Ownable {
    event Received(address from, address to, uint256 amount);

    receive() external payable {
        emit Received(msg.sender, address(this), msg.value);
    }

    function withdraw(address payable bank, uint256 amount) public {
        BigBank(bank).withdraw(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract BigBank is Bank {
    modifier minimumDeposit() {
        require(msg.value > 0.001 ether, "Deposit value must be larger than 0.001 ether");
        _;
    }

    receive() external payable override minimumDeposit {
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, balances[msg.sender]);
    }

    function delegateOwner(address newOwner) public {
        require(msg.sender == owner, "Only owner can delegate ownership to new address");
        owner = newOwner;
    }
}
