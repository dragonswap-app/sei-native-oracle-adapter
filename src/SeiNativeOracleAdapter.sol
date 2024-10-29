// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "./interfaces/ISeiNativeOracle.sol";

library SeiNativeOracleAdapter {
    address internal constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    ISeiNativeOracle internal constant NATIVE_ORACLE = ISeiNativeOracle(ORACLE_PRECOMPILE_ADDRESS);
    uint256 internal constant ORACLE_PRECISION = 18; // decimals

    error InvalidByte(bytes1 b);
    error OutdatedExchangeRate();

    /**
     * @dev Function to get a single token exchange rate from Sei Native Oracle represented in uint256 format.
     * @param denom represents the token name
     */
    function getExchangeRate(string calldata denom) external view returns (uint256 rate) {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = NATIVE_ORACLE.getExchangeRates();
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            ISeiNativeOracle.DenomOracleExchangeRatePair memory pair = data[i];
            if (keccak256(bytes(pair.denom)) == keccak256(bytes(denom))) {
                // Conversion of lastUpdate to uint256. This flow should change.
                uint256 lastUpdate = convertToUint256(bytes(pair.oracleExchangeRateVal.lastUpdate));
                // 5 block / 10 seconds update tolerance.
                if (
                    lastUpdate + 5 < block.number
                        || uint256(uint64(pair.oracleExchangeRateVal.lastUpdateTimestamp)) + 10 < block.timestamp
                ) {
                    revert OutdatedExchangeRate();
                }
                return convertToUint256(bytes(pair.oracleExchangeRateVal.exchangeRate));
            }
        }
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds) external view returns (uint256 twap) {
        ISeiNativeOracle.OracleTwap[] memory data = NATIVE_ORACLE.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return convertToUint256(bytes(data[i].twap));
            }
        }
    }

    /**
     * @dev Function to get all available exchange rates.
     */
    function getExchangeRates() external view returns (uint256[] memory rates) {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = NATIVE_ORACLE.getExchangeRates();
        uint256 length = data.length;
        rates = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            ISeiNativeOracle.DenomOracleExchangeRatePair memory pair = data[i];
            // Conversion of lastUpdate to uint256. This flow should change.
            uint256 lastUpdate = convertToUint256(bytes(pair.oracleExchangeRateVal.lastUpdate));
            // 5 block / 10 seconds update tolerance.
            if (
                lastUpdate + 5 < block.number
                    || uint256(uint64(pair.oracleExchangeRateVal.lastUpdateTimestamp)) + 10 < block.timestamp
            ) {
                revert OutdatedExchangeRate();
            }
            rates[i] = convertToUint256(bytes(pair.oracleExchangeRateVal.exchangeRate));
        }
    }

    function getOracleTwaps(uint64 lookbackSeconds) external view returns (uint256[] memory twaps) {
        ISeiNativeOracle.OracleTwap[] memory data = NATIVE_ORACLE.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        twaps = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            twaps[i] = convertToUint256(bytes(data[i].twap));
        }
    }

    function convertToUint256(bytes memory exchangeRateBytes) public pure returns (uint256 exchangeRateUint256) {
        uint256 length = exchangeRateBytes.length;
        for (uint256 i; i < length; ++i) {
            bytes1 b = exchangeRateBytes[i];
            if (b != 0x2E) {
                if (b < 0x30 || b > 0x39) revert InvalidByte(b);
                exchangeRateUint256 = exchangeRateUint256 * 10 + (uint8(b) - uint8(0x30));
            }
        }
    }
}
