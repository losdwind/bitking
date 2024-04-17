// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.25;

contract Coin {
    address public minter;
    mapping(address => uint) balances;

    event Sent(address from, address to, uint amount);
    error InsufficientBalance(uint required, uint available);

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance({
                required: amount,
                available: balances[msg.sender]
            });
        }

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender, receiver, amount);
    }

    function getBalance() public view returns (uint){
        return balances[msg.sender];
    }
}