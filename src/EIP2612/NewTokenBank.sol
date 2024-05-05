// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./NewToken.sol";

contract NewTokenBank {
    mapping(address => uint) bankBalances;
    address tokenAddress;

    event Deposited(address _from, address _to, uint256 _value);
    event Withdrawed(address _from, address _to, uint256 _value);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function permitDeposit(
        address owner,
        uint value,
        uint nounce,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        NewToken(tokenAddress).permit(
            owner,
            address(this),
            value,
            nounce,
            deadline,
            v,
            r,
            s
        );
        NewToken(tokenAddress).transferFrom(owner, address(this), value);
        bankBalances[owner] += value;
        emit Deposited(owner, address(this), value);
    }

    function deposit(uint256 _value) public {
        require(
            NewToken(tokenAddress).balanceOf(msg.sender) >= _value,
            "Insufficient balance"
        );
        // bytes memory payload = abi.encodeWithSignature("transfer(address, uint)");
        // (bool success, ) = payable(msg.sender).delegatecall(payload);
        require(
            NewToken(tokenAddress).allowance(msg.sender, address(this)) >
                _value,
            "Insufficient allowance"
        );
        // require(success, "Failed to deposit");
        NewToken(tokenAddress).transferFrom(msg.sender, address(this), _value);
        bankBalances[msg.sender] += _value;
        emit Deposited(msg.sender, address(this), _value);
    }

    function withdraw(uint256 _value) public {
        require(bankBalances[msg.sender] >= _value, "Insufficient balance");
        require(
            NewToken(tokenAddress).balanceOf(address(this)) >= _value,
            "Bankcrupted"
        );
        NewToken(tokenAddress).transfer(msg.sender, _value);
        bankBalances[msg.sender] -= _value;
    }
}
