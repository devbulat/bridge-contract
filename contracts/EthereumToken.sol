//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract EthereumToken is Token {
    constructor() Token("Ethereum", "ETH") {}
}