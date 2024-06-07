// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/ETHInscription/Inscription.sol";
import "../../src/ETHInscription/CloneFactory.sol";

contract InscriptionTest is Test {
    address cloneFactoryAddress;
    address implementationAddress;
    address alice;
    address bob;

    function setUp() public {
        implementationAddress = payable(address(new Inscription()));
        cloneFactoryAddress = address(
            new CloneFactory(implementationAddress, 10 ** 17)
        );
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        deal(alice, 10 ** 18);
        deal(bob, 10 ** 18);
        vm.prank(alice);
        console.log("%s", alice);
        console.log(bob);
        console.log(alice.balance);
        console.log(bob.balance);
        console.log(implementationAddress);
        console.log(cloneFactoryAddress);
        CloneFactory(payable(cloneFactoryAddress)).deployInscription(
            "ALICE",
            10000 * 10 ** 18,
            100 * 10 ** 18,
            10 ** 18,
            10 ** 17
        );

        vm.prank(bob);
        CloneFactory(payable(cloneFactoryAddress)).deployInscription(
            "BOB",
            10000 * 10 ** 18,
            100 * 10 ** 18,
            10 ** 18,
            10 ** 17
        );
    }

    // test the inscription is successfully deployed
    function test_shouldDeployInscription() public {
        vm.prank(alice);
        CloneFactory(payable(cloneFactoryAddress)).deployInscription(
            "ALC2",
            10000 * 10 ** 18,
            100 * 10 ** 18,
            10 ** 18,
            10 ** 17
        );
        address aliceInscription2 = CloneFactory(payable(cloneFactoryAddress))
            .allClones(alice, 1);

        vm.assertEq(Inscription(payable(aliceInscription2)).symbol(), "ALC2");
        vm.assertEq(
            Inscription(payable(aliceInscription2)).totalSupplyLimit(),
            10000 * 10 ** 18
        );
        vm.assertEq(
            Inscription(payable(aliceInscription2)).perMint(),
            100 * 10 ** 18
        );
        vm.assertEq(
            Inscription(payable(aliceInscription2)).price(),
            1 * 10 ** 18
        );
        vm.assertEq(
            Inscription(payable(aliceInscription2)).fee(),
            1 * 10 ** 17
        );
    }

    // test mint perMint success
    function test_shouldMintAsPerMint() public {
        vm.deal(alice, 10 ** 18 + 2 * 10 ** 17);
        address aliceInscription = CloneFactory(payable(cloneFactoryAddress))
            .allClones(alice, 0);
        console.log(aliceInscription);
        vm.startPrank(alice);
        CloneFactory(payable(cloneFactoryAddress)).mintInscription{
            value: 10 ** 18 +
                CloneFactory(payable(cloneFactoryAddress)).fee() +
                Inscription(payable(aliceInscription)).fee()
        }(aliceInscription);
        vm.assertEq(
            Inscription(payable(aliceInscription)).balanceOf(alice),
            100 * 10 ** 18
        );
        vm.assertEq(alice.balance, 10**17); // fee
        vm.assertEq(
            Inscription(payable(aliceInscription)).totalSupply(),
            100 * 10 ** 18
        );
    }

    // test split profit between factory provider and inscription creater
    function test_shouldSplitFee() public {
        vm.deal(alice, 10 ** 18 + 2 * 10 ** 17);
        address aliceInscription = CloneFactory(payable(cloneFactoryAddress))
            .allClones(alice, 0);
        console.log(aliceInscription);
        vm.startPrank(alice);
        CloneFactory(payable(cloneFactoryAddress)).mintInscription{
            value: 10 ** 18 +
                CloneFactory(payable(cloneFactoryAddress)).fee() +
                Inscription(payable(aliceInscription)).fee()
        }(aliceInscription);

        vm.assertEq(aliceInscription.balance, 10 ** 18);
        vm.assertEq(alice.balance, 10 ** 17);
        vm.assertEq(cloneFactoryAddress.balance, 10 ** 17);
    }

    // test totalSupplyLimit restrict the user from over minting

    function testFailed_mintMoreThan_totalSupplyLimit() public {
        vm.deal(alice, 100000 * 10 ** 18);
        address aliceInscription = CloneFactory(payable(cloneFactoryAddress))
            .allClones(alice, 0);
        console.log(aliceInscription);
        vm.startPrank(alice);
        for (uint i = 0; i < 100; i++) {
            CloneFactory(payable(cloneFactoryAddress)).mintInscription{
                value: 10 ** 18 +
                    CloneFactory(payable(cloneFactoryAddress)).fee() +
                    Inscription(payable(aliceInscription)).fee()
            }(aliceInscription);
        }

        vm.assertEq(
            Inscription(payable(aliceInscription)).balanceOf(alice),
            10000 * 10 ** 18
        );

        // vm.expectRevert("exceed maximum supply");
        CloneFactory(payable(cloneFactoryAddress)).mintInscription{
            value: 10 ** 18 +
                CloneFactory(payable(cloneFactoryAddress)).fee() +
                Inscription(payable(aliceInscription)).fee()
        }(aliceInscription);
    }
}
