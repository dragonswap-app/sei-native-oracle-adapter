// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {SeiNativeOracleAdapter} from "../src/SeiNativeOracleAdapter.sol";
import {SeiNativeOracle} from "../src/mocks/SeiNativeOracle.sol";

/// @notice Simple manual tests - to ensure validity use real environment and manually check values.
contract SeiNativeOracleAdapterTest is Test {
    // Order: usei, ueth, ubtc.
    uint256[3] cloneRates = [18000000790000000000, 2120555000000000000000, 65179895227000000000000];
    uint256[3] cloneTwaps = [17000225790000000000, 2080113235821123000000, 62057772653314219000002];

    function setUp() public {
        SeiNativeOracle seiNativeOracle = new SeiNativeOracle();
        vm.etch(SeiNativeOracleAdapter.ORACLE_PRECOMPILE_ADDRESS, address(seiNativeOracle).code);
    }

    function test_getExchangeRate() public view {
        string memory denom = "usei";
        uint256 rate = SeiNativeOracleAdapter.getExchangeRate(denom);
        assertEq(rate, cloneRates[0]);
    }

    function test_getExchangeRates() public view {
        (uint256[] memory rates, /*string[] memory denoms*/) = SeiNativeOracleAdapter.getExchangeRates();
        for (uint256 i; i < rates.length; ++i) {
            assertEq(rates[i], cloneRates[i]);
        }
    }

    function test_getOracleTwap() public view {
        string memory denom = "usei";
        uint256 twap = SeiNativeOracleAdapter.getOracleTwap(denom, 10);
        assertEq(twap, cloneTwaps[0]);
    }

    function test_getOracleTwaps() public view {
        (uint256[] memory twaps, /*string[] memory denoms*/) = SeiNativeOracleAdapter.getOracleTwaps(10);
        for (uint256 i; i < twaps.length; ++i) {
            assertEq(twaps[i], cloneTwaps[i]);
        }
    }

    function test_changeDecimals() public view {
        string memory denom = "usei";
        uint256 rate = SeiNativeOracleAdapter.getExchangeRate(denom);
        assertEq(SeiNativeOracleAdapter.changeDecimals(rate, 18, 16), cloneRates[0] / 100);
        assertEq(SeiNativeOracleAdapter.changeDecimals(rate, 18, 20), cloneRates[0] * 100);
    }
}
