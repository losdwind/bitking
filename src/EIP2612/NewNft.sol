// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AJNFT is ERC721 {
    using Strings for uint256;
    string public version = "1";

    uint256 tokenId;

    bytes32 DOMAIN_SEPARATER;
    mapping(address => uint) public nounces;

    constructor(uint _chainId) ERC721("Aijie Royalty NFT", "AJR") {
        tokenId = 1;
        DOMAIN_SEPARATER = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name())),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    function mint() external returns (bool) {
        _mint(msg.sender, tokenId);
        tokenId += 1;
        return true;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        _requireOwned(_tokenId);

        string memory baseURI = _baseURI();
        string memory tokenIdJson = string.concat(_tokenId.toString(), ".json");
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, tokenIdJson)
                : "";
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://ivory-electric-gull-582.mypinata.cloud/ipfs/QmZWGr2CX2jVotWScpPsULNoG1M1KVcBBjCYgDgqetZyUn/";
    }

    function permit(
        address from,
        address to,
        uint nftId,
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
                            "Permit(address from,address to,uint256 nftId,uint256 nonce,uint256 deadline)"
                        ),
                        from,
                        to,
                        nftId,
                        nounce,
                        deadline
                    )
                )
            )
        );
        require(from != address(0), "invalid owner address");
        require(from == ecrecover(digest, v, r, s));
        require(nounce == nounces[from], "invalid nounce");
        require(deadline == 0 || deadline >= block.timestamp);

        approve(to, nftId);

        emit Approval(from, to, nftId);
    }
}
