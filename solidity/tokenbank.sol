// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract TokenBank {
    mapping(address => uint) public balances;
    address public tokenAddress;

    event Deposited(address _from, address _to, uint _value);
    event Withdrawed(address _from, address _to, uint _value);


    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
    }

    function deposit(uint _value) public {
        require(BaseERC20(tokenAddress).balanceOf(msg.sender) >= _value, "Insufficient balance");
        require(BaseERC20(tokenAddress).allowance(msg.sender, address(this)) > _value, "Insufficient allowance");
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

}


contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 ether;

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        balance = balances[_owner];

    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(msg.sender != _to, "Cannot transfer to self");
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(_from != _to, "Cannot transfer to same person");
        require(balances[_from]  >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        require(msg.sender != _spender, "Cannot approve yourself");
        require(balanceOf(msg.sender) >= _value, "Insufficient balance to allow");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
        remaining = allowances[_owner][_spender];
    }
}

