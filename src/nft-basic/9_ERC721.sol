// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AJNFT is ERC721 {
    using Strings for uint;
    uint tokenId;

    constructor() ERC721("Aijie Royalty NFT", "AJR") {
        tokenId = 1;
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
}
