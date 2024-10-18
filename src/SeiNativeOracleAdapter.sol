// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISeiNativeOracle} from "./interfaces/ISeiNativeOracle.sol";

library SeiNativeOracleAdapter {
    address private constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    ISeiNativeOracle private constant ORACLE_CONTRACT = ISeiNativeOracle(ORACLE_PRECOMPILE_ADDRESS);

    /// @dev Hashes used for assertions, also show which tokens are supported.
    bytes32 private constant USEI_DENOM_HASH = keccak256(bytes("usei"));
    bytes32 private constant UETH_DENOM_HASH = keccak256(bytes("ueth"));
    bytes32 private constant UBTC_DENOM_HASH = keccak256(bytes("ubtc"));
    // bytes32 private constant UUSDT_DENOM_HASH = keccak256(bytes("uusdt"));
    // bytes32 private constant UUSDC_DENOM_HASH = keccak256(bytes("uusdc"));
    // bytes32 private constant UATOM_DENOM_HASH = keccak256(bytes("uatom"));
    // bytes32 private constant UOSMO_DENOM_HASH = keccak256(bytes("uosmo"));

    error InvalidByte(bytes1 b);

    /**
     * @dev Function to return decimals of a token supported by the Sei Native Oracle.
     * $SEI  -> 18
     * $ETH  -> 18
     * $WBTC -> 8
     * $USDT -> 6
     * $USDC -> 6
     * $ATOM -> 6
     * $OSMO -> 6
     * @param denom is supported token name represented as a lowercase string with 'u' as a prefix.
     */
    function decimals(string memory denom) public pure returns (uint256) {
        bytes32 denomHash = keccak256(bytes(denom));
        if (denomHash == USEI_DENOM_HASH || denomHash == UETH_DENOM_HASH) {
            return 18;
        } else if (denomHash == UBTC_DENOM_HASH) {
            return 8;
        } else {
            return 6;
        }
    }

    /**
     * @dev Function to get a single token exchange rate from Sei Native Oracle represented in uint256 format.
     * @param denom represents the token name
     */
    function getExchangeRate(string calldata denom, bool applyDecimals)
        external
        view
        returns (uint256 rate, uint256 dec)
    {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return convertExchangeRate(data[i].oracleExchangeRateVal.exchangeRate, denom, applyDecimals);
            }
        }
    }

    function getOracleTwap(string calldata denom, uint64 lookbackSeconds, bool applyDecimals)
        external
        view
        returns (uint256 twap, uint256 dec)
    {
        ISeiNativeOracle.OracleTwap[] memory data = ORACLE_CONTRACT.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        for (uint256 i; i < length; ++i) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return convertExchangeRate(data[i].twap, denom, applyDecimals);
            }
        }
    }

    /**
     * @dev Function to get all available exchange rates.
     * @param applyDecimals describes if decimals should be cropped to fit the token specified decimals or if full precision should be kept.
     */
    function getExchangeRates(bool applyDecimals)
        external
        view
        returns (uint256[] memory rates, uint256[] memory decs)
    {
        ISeiNativeOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        rates = new uint256[](length);
        decs = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            (rates[i], decs[i]) =
                convertExchangeRate(data[i].oracleExchangeRateVal.exchangeRate, data[i].denom, applyDecimals);
        }
    }

    function getOracleTwap(uint64 lookbackSeconds, bool applyDecimals)
        external
        view
        returns (uint256[] memory twaps, uint256[] memory decs)
    {
        ISeiNativeOracle.OracleTwap[] memory data = ORACLE_CONTRACT.getOracleTwaps(lookbackSeconds);
        uint256 length = data.length;
        twaps = new uint256[](length);
        decs = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            (twaps[i], decs[i]) = convertExchangeRate(data[i].twap, data[i].denom, applyDecimals);
        }
    }

    function convertExchangeRate(string memory exchangeRate, string memory denom, bool applyDecimals)
        public
        pure
        returns (uint256 rate, uint256 dec)
    {
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
        uint256 _decimals = decimals(denom);
        // Sei oracle always returns 18 decimals of precision
        // if (length - fixedPointPos < _decimals) {
        //     o *= 10 ** (_decimals - (length - fixedPointPos) + 1);
        // } else
        //
        // ApplyDecimals - users might want to leverage full precision
        // in their calculations instead of rounding up to the token decimals.
        if (length - fixedPointPos > _decimals && applyDecimals) {
            o /= 10 ** ((length - fixedPointPos - 1) - _decimals);
        }
        return (o, applyDecimals ? _decimals : 18);
    }
}
