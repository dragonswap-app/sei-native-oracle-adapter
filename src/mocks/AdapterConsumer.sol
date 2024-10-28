// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SeiNativeOracleAdapter} from "../SeiNativeOracleAdapter.sol";

contract AdapterConsumer {
    function getExchangeRate(string calldata denom, uint256 decimals)
        external
        view
        returns (uint256 rate, uint256 dec)
    {
        return SeiNativeOracleAdapter.getExchangeRate(denom, decimals);
    }

    function getExchangeRates(uint256 decimals) external view returns (uint256[] memory rate, uint256[] memory dec) {
        return SeiNativeOracleAdapter.getExchangeRates(decimals);
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds, uint256 decimals)
        external
        view
        returns (uint256 rate, uint256 dec)
    {
        return SeiNativeOracleAdapter.getOracleTwap(denom, lookbackSeconds, decimals);
    }

    function getOracleTwaps(uint64 lookbackSeconds, uint256 decimals) external view returns (uint256[] memory rate, uint256[] memory dec) {
        return SeiNativeOracleAdapter.getOracleTwaps(lookbackSeconds, decimals);
    }

}
