// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "../interfaces/ISeiNativeOracle.sol";

contract SeiNativeOracle is ISeiNativeOracle {
    DenomOracleExchangeRatePair[] public rates;

    function initialize() external {
        DenomOracleExchangeRatePair memory rate = DenomOracleExchangeRatePair({
            denom: "usei",
            oracleExchangeRateVal: OracleExchangeRate({
                exchangeRate: "18.000000790000000000",
                lastUpdate: "1",
                lastUpdateTimestamp: int64(int256(block.timestamp))
            })
        });

        rates.push(rate);
        rate.denom = "ueth";
        rate.oracleExchangeRateVal.exchangeRate = "2120.555000000000000000";
        rates.push(rate);

        rate.denom = "ubtc";
        rate.oracleExchangeRateVal.exchangeRate = "65179.895227000000000000";

        rates.push(rate);
    }

    function getExchangeRates() external view returns (DenomOracleExchangeRatePair[] memory _rates) {
        _rates = rates;
    }

    function getOracleTwaps(uint64 lookback_seconds) external view returns (OracleTwap[] memory twaps) {}
}
