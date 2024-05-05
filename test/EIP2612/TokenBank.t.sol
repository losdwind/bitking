// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "../../src/EIP2612/NewToken.sol";
import "../../src/EIP2612/NewTokenBank.sol";

import "forge-std/Test.sol";

contract TokenBankTest is Test {
    address newTokenAddress;
    address newTokenBankAddress;
    uint alicePrivateKey;
    uint bobPrivateKey;
    address alice;
    address bob;

    event Deposited(address from, address to, uint value);

    function setUp() public {
        newTokenAddress = address(new NewToken("AJ Coin", "AJC", 11155111));

        newTokenBankAddress = address(new NewTokenBank(newTokenAddress));
        alicePrivateKey = 1;
        bobPrivateKey = 2;

        alice = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);

        NewToken(newTokenAddress).transfer(alice, 1e18);
    }

    function test_permitDeposit() public {
        console.log("alice's wallet address:", alice);
        console.log(
            "alice's balance in token",
            NewToken(newTokenAddress).balanceOf(alice)
        );
        console.log(
            "alice's balance in bank",
            NewTokenBank(newTokenBankAddress).bankBalances(alice)
        );

        // alice generate signature
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NewToken(newTokenAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        newTokenBankAddress,
                        1e18,
                        0,
                        1 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        console.log(
            "now bob using alice's signature to deposit alice's money to bank"
        );
        // bob use signature to deposit successfully
        vm.prank(bob);
        vm.expectEmit();
        emit Deposited(alice, newTokenBankAddress, 1e18);
        NewTokenBank(newTokenBankAddress).permitDeposit(
            alice,
            1e18,
            0,
            1 days,
            v,
            r,
            s
        );

        console.log("alice's wallet address:", alice);
        console.log(
            "alice's updated balance in token",
            NewToken(newTokenAddress).balanceOf(alice)
        );
        console.log(
            "alice's updated balance in bank",
            NewTokenBank(newTokenBankAddress).bankBalances(alice)
        );
    }
}
