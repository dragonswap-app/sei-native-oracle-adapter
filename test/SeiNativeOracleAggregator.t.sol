// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SeiNativeOracleAggregator} from "../src/SeiNativeOracleAggregator.sol";

contract SeiNativeOracleAggregatorTest is Test {
    SeiNativeOracleAggregator public aggregator;

    function setUp() public {
        aggregator = new SeiNativeOracleAggregator();
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
