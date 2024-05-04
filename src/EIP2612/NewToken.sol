// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface TokenRecipient {
    function tokenReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract NewToken is ERC20 {
    string public version = "1";
    bytes32 DOMAIN_SEPARATER;

    mapping(address => uint) public nounces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _chainId
    ) ERC20(_name, _symbol) {
        DOMAIN_SEPARATER = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
        _mint(msg.sender, 1 ether);
    }

    function permit(
        address owner,
        address spender,
        uint value,
        uint nounce,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                DOMAIN_SEPARATER,
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        owner,
                        spender,
                        value,
                        nounce,
                        deadline
                    )
                )
            )
        );
        require(owner != address(0), "invalid owner address");
        require(owner == ecrecover(digest, v, r, s));
        require(nounce == nounces[owner], "invalid nounce");
        require(deadline == 0 || deadline >= block.timestamp);

        _approve(owner, spender, value);

        emit Approval(owner, spender, value);
    }

    function transferWithCallback(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        transfer(recipient, amount);
        uint256 size;
        assembly {
            size := extcodesize(recipient)
        }

        if (size > 0) {
            bool success = TokenRecipient(recipient).tokenReceived(
                msg.sender,
                amount,
                data
            );
            require(success, "No tokens received");
        }

        return true;
    }
}
