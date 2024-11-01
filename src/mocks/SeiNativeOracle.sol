// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "../interfaces/ISeiNativeOracle.sol";

/**
 * THIS IS A MOCK CONTRACT THAT USES UNAUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract SeiNativeOracle is ISeiNativeOracle {

    function getExchangeRates() external view returns (DenomOracleExchangeRatePair[] memory rates) {
        rates = new DenomOracleExchangeRatePair[](3);

        int64 lastUpdateTimestamp = int64(int256(block.timestamp));

        rates[0] = DenomOracleExchangeRatePair({
            denom: "usei",
            oracleExchangeRateVal: OracleExchangeRate({
                exchangeRate: "18.000000790000000000",
                lastUpdate: "1",
                lastUpdateTimestamp: lastUpdateTimestamp
            })
        });

        rates[1] = DenomOracleExchangeRatePair({
            denom: "ueth",
            oracleExchangeRateVal: OracleExchangeRate({
                exchangeRate: "2120.555000000000000000",
                lastUpdate: "1",
                lastUpdateTimestamp: lastUpdateTimestamp
            })
        });

        rates[2] = DenomOracleExchangeRatePair({
            denom: "ubtc",
            oracleExchangeRateVal: OracleExchangeRate({
                exchangeRate: "65179.895227000000000000",
                lastUpdate: "1",
                lastUpdateTimestamp: lastUpdateTimestamp
            })
        });
    }

    function getOracleTwaps(uint64 /*lookback_seconds*/ ) external pure returns (OracleTwap[] memory twaps) {
        twaps = new OracleTwap[](3);

        twaps[0] = OracleTwap({denom: "usei", twap: "17.000225790000000000", lookbackSeconds: int64(10)});
        twaps[1] = OracleTwap({denom: "ueth", twap: "2080.113235821123000000", lookbackSeconds: int64(10)});
        twaps[2] = OracleTwap({denom: "ubtc", twap: "62057.772653314219000002", lookbackSeconds: int64(10)});
    }
}
