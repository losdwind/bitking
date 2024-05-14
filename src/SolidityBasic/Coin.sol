// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.25;

contract Coin {
    address public minter;
    mapping(address => uint256) balances;

    event Sent(address from, address to, uint256 amount);

    error InsufficientBalance(uint256 required, uint256 available);

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    function send(address receiver, uint256 amount) public {
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance({required: amount, available: balances[msg.sender]});
        }

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender, receiver, amount);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
