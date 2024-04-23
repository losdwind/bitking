// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./8_ERC_20_Extended.sol";

contract TokenBank  is TokenRecipient{
    mapping(address => uint) public balances;
    address public tokenAddress;

    event Deposited(address _from, address _to, uint _value);
    event Withdrawed(address _from, address _to, uint _value);


    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
    }

    function deposit(uint _value) public {
        require(BaseERC20(tokenAddress).balanceOf(msg.sender) >= _value, "Insufficient balance");
        // bytes memory payload = abi.encodeWithSignature("transfer(address, uint)");
        // (bool success, ) = payable(msg.sender).delegatecall(payload);
        require(BaseERC20(tokenAddress).allowance(msg.sender, address(this)) > _value, "Insufficient allowance");
        // require(success, "Failed to deposit");
        BaseERC20(tokenAddress).transferFrom(msg.sender, address(this), _value);
        balances[msg.sender]  += _value;
        emit Deposited(msg.sender, address(this), _value);
    }

    function withdraw(uint _value) public{
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(BaseERC20(tokenAddress).balanceOf(address(this)) >= _value, "Bankcrupted");
        BaseERC20(tokenAddress).transfer(msg.sender,_value);
        balances[msg.sender] -= _value;
    }

    function tokenReceived(address sender, uint256 amount) external returns(bool){
        balances[sender]  += amount;
        emit Deposited(sender, address(this), amount);
        return true;
    }

}
