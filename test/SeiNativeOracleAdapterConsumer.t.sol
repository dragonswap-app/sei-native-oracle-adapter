// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AdapterConsumer} from "../src/mocks/AdapterConsumer.sol";
import {SeiNativeOracle} from "../src/mocks/SeiNativeOracle.sol";

contract SeiNativeOracleAdapterConsumerTest is Test {
    AdapterConsumer public adapterConsumer;
    SeiNativeOracle public seiNativeOracle;

    address public constant ORACLE_ADDRESS = 0x0000000000000000000000000000000000001008;

    function setUp() public {
        adapterConsumer = new AdapterConsumer();
        seiNativeOracle = new SeiNativeOracle();
        vm.etch(ORACLE_ADDRESS, address(seiNativeOracle).code);
        seiNativeOracle = SeiNativeOracle(ORACLE_ADDRESS);
    }

    function test_getExchangeRate() public view {
        uint256 rate = adapterConsumer.getExchangeRate("usei");
        console.log(rate);
        console.log(adapterConsumer.changeDecimals(rate, 18, 16));
        console.log(adapterConsumer.changeDecimals(rate, 18, 20));
    }

    function test_getExchangeRates() public view {
        (uint256[] memory rates, string[] memory denoms) = adapterConsumer.getExchangeRates();
        for (uint256 i; i < rates.length; ++i) {
            console.log(rates[i], denoms[i]);
        }
    }

    function test_getOracleTwap() public view {
        uint256 twap = adapterConsumer.getOracleTwap("usei", 10);
        console.log(twap);
    }

    function test_getOracleTwaps() public view {
        (uint256[] memory twaps, string[] memory denoms) = adapterConsumer.getOracleTwaps(10);
        for (uint256 i; i < twaps.length; ++i) {
            console.log(twaps[i], denoms[i]);
        }
    }
}
