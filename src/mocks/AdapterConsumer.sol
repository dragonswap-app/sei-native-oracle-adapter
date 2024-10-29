// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SeiNativeOracleAdapter} from "../SeiNativeOracleAdapter.sol";

contract AdapterConsumer {
    function getExchangeRate(string calldata denom) external view returns (uint256 rate) {
        return SeiNativeOracleAdapter.getExchangeRate(denom);
    }

    function getExchangeRates() external view returns (uint256[] memory rate) {
        return SeiNativeOracleAdapter.getExchangeRates();
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds) external view returns (uint256 rate) {
        return SeiNativeOracleAdapter.getOracleTwap(denom, lookbackSeconds);
    }

    function getOracleTwaps(uint64 lookbackSeconds) external view returns (uint256[] memory rate) {
        return SeiNativeOracleAdapter.getOracleTwaps(lookbackSeconds);
    }
}
