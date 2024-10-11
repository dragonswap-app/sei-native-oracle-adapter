// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOracle} from "./interfaces/ISeiNativeOracle.sol";

contract SeiNativeOracleAggregator {

    mapping(string denom => uint256 decimals) public decimals;

    address constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001008;
    IOracle constant ORACLE_CONTRACT = IOracle(ORACLE_PRECOMPILE_ADDRESS);

    error InvalidByte(bytes1 b);

    constructor() {
        decimals["usei"] = 18;
        decimals["uatom"] = 6;
        decimals["uosmo"] = 6;
        decimals["ueth"] = 18;
        decimals["ubtc"] = 8;
        decimals["uusdt"] = 6;
        decimals["uusdc"] = 6;
    }

    function getExchangeRate(string memory denom) external view returns (uint256 rate, uint256 dec) {
        IOracle.DenomOracleExchangeRatePair[] memory data = ORACLE_CONTRACT.getExchangeRates();
        uint256 length = data.length;
        for(uint256 i; i < length; i++) {
            if (keccak256(bytes(data[i].denom)) == keccak256(bytes(denom))) {
                return (convertExchangeRate(data[i].oracleExchangeRateVal.exchangeRate, denom), decimals[denom]);
            }
        }
    }

    function convertExchangeRate(string memory exchangeRate, string memory denom) public view returns (uint256) {
        bytes memory e = bytes(exchangeRate);
        uint256 length = e.length;
        uint256 o;
        uint256 fixedPointPos;
        for(uint256 i; i < length; i++) {
            bytes1 b = e[i];
            if (b != 0x2E) {
                if (b < 0x30 || b > 0x39) revert InvalidByte(b);
                o = o * 10 + (uint8(b) - uint8(0x30));
            } else {
                fixedPointPos = i;
            }
        }
        uint256 _decimals = decimals[denom];
        if (length - fixedPointPos < _decimals) {
            o *= 10 ** (_decimals - (length - fixedPointPos) + 1);
        } else if (length - fixedPointPos > _decimals) {
            o /= 10 ** ((length - fixedPointPos - 1) - _decimals);
        }
        return o;
    }
}
