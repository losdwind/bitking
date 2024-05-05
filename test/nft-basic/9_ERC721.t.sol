// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../../src/nft-basic/9_ERC721.sol";

contract NftTest is Test {
    AJNFT nft;

    function setUp() public {
        nft = new AJNFT();
    }

    function test_mint() public {
        nft.mint();
        assertEq(nft.balanceOf(address(this)), 1);
    }
}
