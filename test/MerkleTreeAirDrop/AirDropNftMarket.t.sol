// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../../src/MerkleTreeAirDropNftMarket/AirDropNftMarket.sol";

contract AirDropNftMarketTest is Test {
    address nftAddress;
    address tokenAddress;
    address airDropAddress;
    bytes32 merkleRootHash;
    address[] whitelist;

    function setUp() public {
        nftAddress = address(new NewNft(11155111));
        tokenAddress = address(new NewToken("New Token", "NTO", 11155111));
        merkleRootHash = 0x8a94af51895b063f4d535e05f9cba8726d38c55413ac187832792934d17b97a5;
        airDropAddress = address(new AirDropNftMarket(tokenAddress, nftAddress, merkleRootHash));
    }

    function test_multicall() public {
        uint256 alicePrivateKey = 1;
        uint256 bobPrivateKey = 2;
        address alice = vm.addr(alicePrivateKey); //0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
        console.log("alice", alice);
        address bob = vm.addr(bobPrivateKey); // 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
        console.log("bob", bob);
        // alice mint a nft
        vm.prank(alice);
        NewNft(nftAddress).mint();
        // bob get the money to buy nft
        NewToken(tokenAddress).transfer(bob, 1e18);

        console.log("Alice has minted a NFT with ID:", NewNft(nftAddress).tokenId() - 1);
        console.log("Alice has token balance of", NewToken(tokenAddress).balanceOf(alice));

        uint256 timestamp = block.timestamp;
        // alice sign the permit
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NewNft(nftAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint price,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        airDropAddress,
                        0,
                        1e18,
                        0,
                        timestamp + 2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        console.log("Alice generated the signature for digest");

        // bob approve
        vm.prank(bob);
        NewToken(tokenAddress).approve(airDropAddress, 1e18);

        vm.prank(bob);
        bytes memory func1 = abi.encodeWithSelector(
            AirDropNftMarket.permitPrePay.selector, alice, airDropAddress, 0, 1e18, 0, timestamp + 2 days, v, r, s
        );

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xbad4f0cf0243d3e2e1d5a5649263d56c42dc9db9d18676af1162745044733ae3;
        proof[1] = 0xe8967264eebd742de9a5f274463cba71c94ae11b10c5ca884609ebccede98ad9;
        bytes memory func2 = abi.encodeWithSelector(
            AirDropNftMarket.claimNFT.selector,
            alice,
            0,
            proof
        );
        bytes[] memory functions = new bytes[](2);
        functions[0] = func1;
        functions[1] = func2;
        AirDropNftMarket(airDropAddress).multiDelegatecallBuy(functions);
        // AirDropNftMarket(airDropAddress).claimNFT(alice, 0, proof);
    }
}
