// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

contract Inscription is ERC20 {
    bool isBase;
    address owner;
    uint permint;

    constructor() ERC20("Base Token", "BAT") {
        isBase = true;
    }

    function initialize(
        address _owner,
        string calldata _name,
        string calldata _symbol,
        uint _totalSupply,
        uint _permint
    ) external {
        require(!isBase, "this contract has been initialized");
        require(owner == address(0), "this contract has been initialized");
        owner = _owner;
        permint = _permint;
        _totalSupply = _totalSupply;
        _name = _name;
        _symbol = _symbol;
    }

    function mint(address account) external {
        _mint(account, permint);
    }
}

interface Implementation {
    function initialize(
        address,
        string calldata,
        string calldata,
        uint,
        uint
    ) external;
}

contract CloneFactory {
    address immutable baseContract;
    mapping(address => address[]) allClones;

    constructor(address _baseContract) {
        baseContract = _baseContract;
    }

    function clone(
        string calldata _name,
        string calldata _symbol,
        uint _totalSupply,
        uint _permint
    ) external {
        address child = Clones.clone(baseContract);
        Implementation(child).initialize(
            msg.sender,
            _name,
            _symbol,
            _totalSupply,
            _permint
        );
        allClones[msg.sender].push(child);
    }

    function returnClones(
        address _owner
    ) external view returns (address[] memory) {
        return allClones[_owner];
    }
}
