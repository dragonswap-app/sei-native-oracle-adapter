// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ISeiNativeOracle} from "../interfaces/ISeiNativeOracle.sol";

contract SeiNativeOracle is ISeiNativeOracle {

    function getExchangeRates() external view returns (DenomOracleExchangeRatePair[] memory rates) {
        rates = new DenomOracleExchangeRatePair[](7);
        rates[0] = DenomOracleExchangeRatePair({
            denom: "usei",
            oracleExchangeRateVal: OracleExchangeRate({
                exchangeRate: "18.0000007900000000000",
                lastUpdate: "1",
                lastUpdateTimestamp: int64(int256(block.timestamp))
            })
        });
    }

    function getOracleTwaps(uint64 lookback_seconds) external view returns (OracleTwap[] memory twaps) {

    }
}
