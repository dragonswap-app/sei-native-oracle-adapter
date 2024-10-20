// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AdapterConsumer} from "../src/mocks/AdapterConsumer.sol";
import {SeiNativeOracle} from "../src/mocks/SeiNativeOracle.sol";

contract SeiNativeOracleConsumerTest is Test {
    AdapterConsumer public adapterConsumer;
    SeiNativeOracle public seiNativeOracle;

    address public constant ORACLE_ADDRESS = 0x0000000000000000000000000000000000001008;

    function setUp() public {
        adapterConsumer = new AdapterConsumer();
        seiNativeOracle = new SeiNativeOracle();
        vm.etch(ORACLE_ADDRESS, address(seiNativeOracle).code);
        seiNativeOracle = SeiNativeOracle(ORACLE_ADDRESS);
        seiNativeOracle.initialize();
    }

    function test_getExchangeRate() public {
        (uint256 rate,) = adapterConsumer.getExchangeRate("usei", false);
        console.log(rate);
    }

    function test_getExchangeRates() public {
        (uint256[] memory rates,) = adapterConsumer.getExchangeRates(false);
        for (uint256 i; i < rates.length; ++i) {
            console.log(rates[i]);
        }
    }

    function test_getOracleTwap() public {
        (uint256 twap,) = adapterConsumer.getOracleTwap("usei", 10, false);
        console.log(twap);
    }

    function test_getOracleTwaps() public {
        (uint256[] memory twaps,) = adapterConsumer.getOracleTwaps(10, false);
        for (uint256 i; i < twaps.length; ++i) {
            console.log(twaps[i]);
        }
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
