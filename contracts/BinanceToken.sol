//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract BinanceToken is Token {
    constructor() Token("Ethereum", "ETH") {}
}