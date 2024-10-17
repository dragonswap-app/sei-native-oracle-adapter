// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ISeiNativeOracle {
    // Queries
    function getExchangeRates() external view returns (DenomOracleExchangeRatePair[] memory);
    function getOracleTwaps(uint64 lookback_seconds) external view returns (OracleTwap[] memory);

    // Structs
    struct OracleExchangeRate {
        string exchangeRate;
        string lastUpdate;
        int64 lastUpdateTimestamp;
    }

    struct DenomOracleExchangeRatePair {
        string denom;
        OracleExchangeRate oracleExchangeRateVal;
    }

    struct OracleTwap {
        string denom;
        string twap;
        int64 lookbackSeconds;
    }
}
