pragma solidity 0.8.25;

contract MyWallet { 
    string public name;
    mapping (address => bool) private approved;
    address public owner;

    modifier auth {
        require (msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    } 

    function transferOwernship(address _addr) public auth {
        require(_addr!=address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        assembly {
            sstore(owner.slot, _addr)
        }
    }
}
contract MyWallet2 {
    string public name;
    mapping(address => bool) private approved;
    address public owner;

    modifier auth {
        // Inline assembly to load the owner from storage slot 0
        address _owner;
        assembly {
            _owner := sload(0)
        }
        require(msg.sender == _owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        // Inline assembly to set the owner to msg.sender
        assembly {
            sstore(0, caller())
        }
    }

    function transferOwnership(address _addr) public auth {
        require(_addr != address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        // Inline assembly to set the new owner
        assembly {
            sstore(0, _addr)
        }
    }
}
