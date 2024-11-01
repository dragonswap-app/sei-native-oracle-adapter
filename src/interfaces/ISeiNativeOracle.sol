// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @notice https://github.com/sei-protocol/sei-chain/blob/1b0323cd5c9aa225365e5039ac2707c949d18ce4/precompiles/oracle/Oracle.sol
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
