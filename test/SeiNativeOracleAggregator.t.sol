// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WrapperUser} from "../src/test/WrapperUser.sol";

contract SeiNativeOracleAggregatorTest is Test {
    WrapperUser public wrapperUser;

    function setUp() public {
        wrapperUser = new WrapperUser();
    }

    function test_Increment() public {
        //aggregator.increment();
        //assertEq(aggregator.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        //counter.setNumber(x);
        //assertEq(counter.number(), x);
    }
}
