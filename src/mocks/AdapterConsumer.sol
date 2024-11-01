// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SeiNativeOracleAdapter} from "../SeiNativeOracleAdapter.sol";

contract AdapterConsumer {
    function getExchangeRate(string calldata denom) external view returns (uint256 rate) {
        return SeiNativeOracleAdapter.getExchangeRate(denom);
    }

    function getExchangeRates() external view returns (uint256[] memory rates, string[] memory denoms) {
        return SeiNativeOracleAdapter.getExchangeRates();
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds) external view returns (uint256 rate) {
        return SeiNativeOracleAdapter.getOracleTwap(denom, lookbackSeconds);
    }

    function getOracleTwaps(uint64 lookbackSeconds) external view returns (uint256[] memory rates, string[] memory denoms) {
        return SeiNativeOracleAdapter.getOracleTwaps(lookbackSeconds);
    }

    function changeDecimals(uint256 number, uint256 fromDecimals, uint256 toDecimals) external pure returns (uint256) {
        return SeiNativeOracleAdapter.changeDecimals(number, fromDecimals, toDecimals);
    }
}
