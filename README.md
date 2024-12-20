# Sei Native Oracle Adapter Library
![unit tests](https://github.com/dragonswap-app/sei-native-oracle-adapter/actions/workflows/test.yml/badge.svg)
[![npm version](https://img.shields.io/npm/v/sei-native-oracle-adapter)](https://www.npmjs.org/package/sei-native-oracle-adapter)

A library that enables an out-of-the-box utilization of the Sei Native Oracle though the Solidity smart-contracts.
The Sei Native Oracle returns 18 decimal fixed point numbers in a `string` format (which is usually not directly usable), and this library helps you easily retrieve exchange rates in `uint256` format with a manageable amount decimals.

## Functionalities

### getExchangeRates()
- Function that provides the ability to retrieve all available exchange rates converted to `uint256` and with maximum precision to the contracts which utilize the adapter.
- Returns: `rates[]` and `denoms[]` (denoms is needed in order to map rates to tokens, which enables contextual usage of the retrieved data)

### getExchangeRate(string memory denom)
- Function that provides the ability to retrieve an exchange rate converted to `uint256` and with maximum precision.
- Denom is computed by appending lowercase character 'u' to the lowercase token symbol (ex. 'usei', 'ueth', 'ubtc').
- In case of an unsupported denom, returned exchange rate will be zero.
- Returns: `rate`

### getOracleTwaps(uint64 lookbackSeconds)
- Function that provides all available time weighed average prices of tokens converted to `uint256` and with maximum precision for a chosen timespan.
- Timespan is a time range between `block.timestamp` and `block.timestamp - lookbackSeconds`.
- Returns: `twaps[]` +  `denoms[]` (denoms array helps adapter/oracle consumers use data in context)

### getOracleTwap(uint64 lookbackSeconds, string memory denom)
- Function that provides a time weighed average price of a chosen token/denom in a timespan determined by `lookbackSeconds`.
- Returns: `twap`

### convertBytesNumberToUint256(bytes memory bytesNumber)
- Function that converts a number from fixed point bytes representation (which was previously casted from `string` representation) to uint256.
- Returns: `uint256Number` -> converted number

### changeDecimals(uint256 number, uint256 fromDecimals, uint256 toDecimals)
- Function that changes decimals on a provided number by either appending zeroes to it or trimming it for a specified number of decimals.
- This function is not directly used in any of the existing flows, but it is made to let consumers manually adapt decimals on need.
- Can utilize the informative ORACLE_PRECISION constant.
- Returns: `number` -> number with modified decimals
 
*_Rates/Prices are represented in USD value_

## Usage
### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

## License
MIT
