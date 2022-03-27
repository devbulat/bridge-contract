//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Bridge.sol";

contract EthereumBridge is Bridge {
    constructor(address tokenAddress) Bridge(tokenAddress) {}
}