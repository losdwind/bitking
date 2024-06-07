pragma solidity 0.8.25;

import {IDO} from "./IDO.sol";
import {RNT} from "../Staking/Staking.sol";
import "forge-std/Test.sol";

contract IDOTest is Test {
    address ido;
    address rnt;

    function setUp() public {
        // rnt = address(new RNT());
        // ido = address(new IDO());
    }
}
