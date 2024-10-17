// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOracle} from "./interfaces/ISeiNativeOracle.sol";

library SeiNativeOracleAdapter {
    address constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    IOracle constant ORACLE_CONTRACT = IOracle(ORACLE_PRECOMPILE_ADDRESS);

    bytes32 internal constant USEI_DENOM_HASH = keccak256(bytes("usei"));
    // bytes32 constant UATOM_DENOM_HASH = keccak256(bytes("uatom"));
    // bytes32 constant UOSMO_DENOM_HASH = keccak256(bytes("uosmo"));
    bytes32 internal constant UETH_DENOM_HASH = keccak256(bytes("ueth"));
    bytes32 internal constant UBTC_DENOM_HASH = keccak256(bytes("ubtc"));
    // bytes32 constant UUSDT_DENOM_HASH = keccak256(bytes("uusdt"));
    // bytes32 constant UUSDC_DENOM_HASH = keccak256(bytes("uusdc"));

    error InvalidByte(bytes1 b);

    function decimals(string calldata denom) public pure returns (uint256) {
        bytes32 denomHash = keccak256(bytes(denom));
        if (denomHash == USEI_DENOM_HASH || denomHash == UETH_DENOM_HASH) {
            return 18;
        } else if (denomHash == UBTC_DENOM_HASH) {
            return 8;
        } else {
            return 6;
        }
    }

    function getExchangeRate(string calldata denom, bool applyDecimals)
        external
        view
        returns (uint256 rate, uint256 dec)
    {
        IOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        for (uint256 i; i < length; i++) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return convertExchangeRate(data[i].oracleExchangeRateVal.exchangeRate, denom, applyDecimals);
            }
        }
    }

    function convertExchangeRate(string memory exchangeRate, string calldata denom, bool applyDecimals)
        public
        pure
        returns (uint256 rate, uint256 dec)
    {
        bytes memory e = bytes(exchangeRate);
        uint256 length = e.length;
        uint256 o;
        uint256 fixedPointPos;
        for (uint256 i; i < length; i++) {
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
