// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AdapterConsumer} from "../src/test/AdapterConsumer.sol";

contract SeiNativeOracleConsumerTest is Test {
    AdapterConsumer public adapterConsumer;

    function setUp() public {
        adapterConsumer = new AdapterConsumer();
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
