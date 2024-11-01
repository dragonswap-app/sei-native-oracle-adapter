// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "./interfaces/ISeiNativeOracle.sol";

/// @notice Purpose of the adapter is to retrieve available information (string) from the Sei Native Oracle and convert it to usable format (uint256).
library SeiNativeOracleAdapter {
    /// @dev Sei Native Oracle precompile address.
    address internal constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    /// @dev Sei Native Oracle interactive instance.
    ISeiNativeOracle internal constant NATIVE_ORACLE = ISeiNativeOracle(ORACLE_PRECOMPILE_ADDRESS);
    /// @dev Sei Native Oracle exchange rate precision (decimals).
    uint256 internal constant ORACLE_PRECISION = 18;

    /// @dev Protects from an unexpected character occurrence in exchange rate byte-string.
    error InvalidByte(bytes1 b);
    /// @dev Protects from an outdated exchange rates.
    error OutdatedExchangeRate();

    /**
     * @dev Function to get a single token exchange rate from Sei Native Oracle represented in uint256 format.
     * @param denom represents the token name.
     * @dev denoms are computed via: 'u' + lowercase token symbol (ex. 'ubtc', 'usei', 'ueth').
     * @return rate is the latest exchange rate for the given token/denom.
     * @dev Value of `rate` will be zero in case of an unsupported token/denom.
     */
    function getExchangeRate(string calldata denom) internal view returns (uint256 rate) {
        // Retrieve exchange rates in default/string format from the native oracle.
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = NATIVE_ORACLE.getExchangeRates();
        // Gas opt.
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            // Gas opt.
            ISeiNativeOracle.DenomOracleExchangeRatePair memory pair = data[i];
            // Compare string hashes and proceed once the matching occurs.
            if (keccak256(bytes(pair.denom)) == keccak256(bytes(denom))) {
                // Conversion of lastUpdate to uint256.
                uint256 lastUpdate = convertToUint256(bytes(pair.oracleExchangeRateVal.lastUpdate));
                // 5 block / 10 seconds update tolerance.
                if (
                    lastUpdate + 5 < block.number
                        || uint256(uint64(pair.oracleExchangeRateVal.lastUpdateTimestamp)) + 10 < block.timestamp
                ) {
                    revert OutdatedExchangeRate();
                }
                // Return converted exchange rate.
                rate = convertToUint256(bytes(pair.oracleExchangeRateVal.exchangeRate));
            }
        }
    }

    /**
     * @dev Function to get time weighed average price for the given token and time period.
     * @param denom represents the token name.
     * @param lookbackSeconds represents number of seconds since the current moment, meaning time period is from `block.timestamp` to `block.timestamp - lookbackSeconds`
     * @return twap is time weighet average price for the given token and time period.
     * @dev Function will return zero in case of an unsupported token or missing feed.
     */
    function getOracleTwap(string calldata denom, uint64 lookbackSeconds) internal view returns (uint256 twap) {
        // Retrieve twap values in the default/string format from the native oracle.
        ISeiNativeOracle.OracleTwap[] memory data = NATIVE_ORACLE.getOracleTwaps(lookbackSeconds);
        // Gas opt.
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            // Compare string hashes and proceed once the matching occurs.
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                // Return converted twap value.
                twap = convertToUint256(bytes(data[i].twap));
            }
        }
    }

    /**
     * @dev Function to get all available exchange rates.
     * @return denoms are denoms of all the available tokens/exchange rates.
     * @param rates are the latest exchange rates available, converted to uint256.
     */
    function getExchangeRates() internal view returns (string[] memory denoms, uint256[] memory rates) {
        // Retrieve exchange rates in default/string format from the native oracle.
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = NATIVE_ORACLE.getExchangeRates();
        // Gas opt.
        uint256 length = data.length;
        // Initialize rates array.
        rates = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            // Gas opt.
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
            // Assign rates and denoms.
            denoms[i] = pair.denom;
            rates[i] = convertToUint256(bytes(pair.oracleExchangeRateVal.exchangeRate));
        }
    }

    /**
     * @dev Function to get twaps for all available tokens/denoms and given amount of lookback seconds.
     * @return denoms are denoms of all the available tokens/twaps.
     * @return twaps are all available time weighed average prices for a given amount of lookback seconds, converted to uint256.
     */
    function getOracleTwaps(uint64 lookbackSeconds) internal view returns (string[] memory denoms, uint256[] memory twaps) {
        // Retrieve twap values in the default/string format from the native oracle.
        ISeiNativeOracle.OracleTwap[] memory data = NATIVE_ORACLE.getOracleTwaps(lookbackSeconds);
        // Gas opt.
        uint256 length = data.length;
        // Initialize twaps array.
        twaps = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            ISeiNativeOracle.OracleTwap memory twap = data[i];
            // Assign twaps and denoms.
            denoms[i] = twap.denom;
            twaps[i] = convertToUint256(bytes(twap.twap));
        }
    }

    /**
     * @dev Function to convert exchange rate into uint256 format.
     * @param exchangeRateBytes is exchange rate in bytes dynamic format.
     * @return exchangeRateUint256 is exchange rate in uint256 static format.
     */
    function convertToUint256(bytes memory exchangeRateBytes) internal pure returns (uint256 exchangeRateUint256) {
        // Gas opt.
        uint256 length = exchangeRateBytes.length;
        for (uint256 i; i < length; ++i) {
            // Gas opt.
            bytes1 b = exchangeRateBytes[i];
            // Check if current byte contains '.'.
            if (b != 0x2E) {
                // Check if current byte takes place in the number characters range.
                if (b < 0x30 || b > 0x39) revert InvalidByte(b);
                // Append the number to the exchange rate value.
                exchangeRateUint256 = exchangeRateUint256 * 10 + (uint8(b) - uint8(0x30));
            }
        }
    }

    /**
     * @dev Function to trim or extend decimals. Meant to be used with converted exchange rate.
     * @param number is the number whichs decimals are to be changed. Usually exchange rate, but can be anything else.
     * @param fromDecimals is the amount of decimals present in the current representation of the 'number'.
     * @param toDecimals is the amount of decimals to be present in the modified representation of the 'number'.
     */
    function changeDecimals(uint256 number, uint256 fromDecimals, uint256 toDecimals) internal pure returns (uint256) {
        // Compare decimals.
        if (toDecimals > fromDecimals) {
            // Append zeroes.
            number *= 10**(toDecimals - fromDecimals);
        } else if (fromDecimals > toDecimals) {
            // Trim decimals.
            number /= 10**(fromDecimals - toDecimals);
        }
        return number;
    }
}
