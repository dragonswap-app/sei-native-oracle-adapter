// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "./interfaces/ISeiNativeOracle.sol";

library SeiNativeOracleAdapter {
    address private constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    ISeiNativeOracle private constant ORACLE_CONTRACT = ISeiNativeOracle(ORACLE_PRECOMPILE_ADDRESS);

    error InvalidByte(bytes1 b);
    error OutdatedExchangeRate();

    /**
     * @dev Function to get a single token exchange rate from Sei Native Oracle represented in uint256 format.
     * @param denom represents the token name
     */
    function getExchangeRate(string calldata denom, uint256 decimals)
        external
        view
        returns (uint256 rate, uint256 dec)
    {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                // Conversion of lastUpdate to uint256. This flow should change.
                (uint256 lastUpdate,) = convertToUint256(data[i].oracleExchangeRateVal.lastUpdate, 18 // TODO: Change this.
                );
                // 5 block update tolerance.
                if (lastUpdate + 5 < block.number) revert OutdatedExchangeRate();
                return convertToUint256(data[i].oracleExchangeRateVal.exchangeRate, decimals);
            }
        }
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds, uint256 decimals)
        external
        view
        returns (uint256 twap, uint256 dec)
    {
        ISeiNativeOracle.OracleTwap[] memory data = ORACLE_CONTRACT.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return convertToUint256(data[i].twap, decimals);
            }
        }
    }

    /**
     * @dev Function to get all available exchange rates.
     */
    function getExchangeRates(uint256 decimals)
        external
        view
        returns (uint256[] memory rates, uint256[] memory decs)
    {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        rates = new uint256[](length);
        decs = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            // Conversion of lastUpdate to uint256. This flow should change.
            (uint256 lastUpdate,) = convertToUint256(data[i].oracleExchangeRateVal.lastUpdate, 18);
            // 5 block update tolerance.
            if (lastUpdate + 5 < block.number) revert OutdatedExchangeRate();
            (rates[i], decs[i]) =
                convertToUint256(data[i].oracleExchangeRateVal.exchangeRate, decimals);
        }
    }

    function getOracleTwaps(uint64 lookbackSeconds, uint256 decimals)
        external
        view
        returns (uint256[] memory twaps, uint256[] memory decs)
    {
        ISeiNativeOracle.OracleTwap[] memory data = ORACLE_CONTRACT.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        twaps = new uint256[](length);
        decs = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            (twaps[i], decs[i]) = convertToUint256(data[i].twap, decimals);
        }
    }

    function convertToUint256(string memory exchangeRate, uint256 decimals)
        public
        pure
        returns (uint256 rate, uint256 dec)
    {
        decimals = decimals == 0 ? 18 : decimals;
        bytes memory e = bytes(exchangeRate);
        uint256 length = e.length;
        uint256 o;
        uint256 fixedPointPos;
        for (uint256 i; i < length; ++i) {
            bytes1 b = e[i];
            if (b != 0x2E) {
                if (b < 0x30 || b > 0x39) revert InvalidByte(b);
                o = o * 10 + (uint8(b) - uint8(0x30));
            } else {
                fixedPointPos = i;
            }
        }
        // Sei oracle always returns 18 decimals of precision
        // if (length - fixedPointPos < _decimals) {
        //     o *= 10 ** (_decimals - (length - fixedPointPos) + 1);
        // } else
        //
        // ApplyDecimals - users might want to leverage full precision
        // in their calculations instead of rounding up to the token decimals.
        if (length - fixedPointPos > decimals) {
            o /= 10 ** ((length - fixedPointPos - 1) - decimals);
        }
        return (o, decimals);
    }
}
