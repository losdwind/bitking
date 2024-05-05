// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "forge-std/console.sol";

contract Inscription is ERC20Upgradeable {
    bool isBase;
    address public owner;
    uint public perMint;
    uint public price;
    uint public totalSupplyLimit;
    uint public fee;

    constructor() {
        // _disableInitializers();
        isBase = true;
    }

    receive() external payable {}

    function initialize(
        address _owner,
        string calldata _symbol,
        uint _totalSupplyLimit,
        uint _perMint,
        uint _price,
        uint _fee
    ) external initializer {
        require(isBase == false, "this contract has been initialized");
        require(owner == address(0), "this contract has been initialized");
        console.log("require meet");
        __ERC20_init(_symbol, _symbol);
        owner = _owner;
        perMint = _perMint;
        totalSupplyLimit = _totalSupplyLimit;
        price = _price;
        fee = _fee;
    }

    function mint(address account) external payable {
        console.log(msg.sender);
        console.log(msg.sender.balance);
        require(msg.value >= price + fee, "no sufficient transfer value");

        require(
            totalSupply() < totalSupplyLimit - perMint,
            "exceed maximum supply"
        );
        _mint(account, perMint);
        payable(owner).transfer(fee);
    }
}
