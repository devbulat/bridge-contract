//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract Bridge {
    address private validator;
    Token token;
    mapping(address => mapping(uint => bool)) public swapNonces;
    mapping(address => mapping(uint => bool)) public redeemNonces;

    event SwapInitialized(
        address sender,
        address recipient, 
        uint256 amount, 
        uint256 chainFrom, 
        uint256 chainTo, 
        uint256 nonce
    );

    event Redeem(
        address sender,
        address recipient, 
        uint256 amount, 
        uint256 chainFrom, 
        uint256 chainTo, 
        uint256 nonce
    );

    constructor(address tokenAddress) {
        validator = msg.sender;
        token = Token(tokenAddress);
    }

    function swap(address recipient, uint256 amount, uint256 chainFrom, uint256 chainTo, uint256 nonce) public  {
        require(swapNonces[msg.sender][nonce] == false, "Swap already in process");
        swapNonces[msg.sender][nonce] = true;
        token.burn(msg.sender, amount);

        emit SwapInitialized(msg.sender, recipient, amount, chainFrom, chainTo, nonce);
    }

    function redeem(address sender, address recipient, uint256 amount, uint256 chainFrom, uint256 chainTo, uint256 nonce) public  {
        require(redeemNonces[sender][nonce] == false, "Redeem already in process");
        redeemNonces[sender][nonce] = true;
        token.mint(recipient, amount);

        emit SwapInitialized(sender, recipient, amount, chainFrom, chainTo, nonce);
    }


    function checkSign(address addr, uint256 val, uint8 v, bytes32 r, bytes32 s) public view returns (bool)  {
        //Method should be invoked in js-side.
        bytes32 message = keccak256(abi.encodePacked(addr, val));
        address addressForCheck = ecrecover(hashMessage(message), v, r, s);

        if (addressForCheck == validator) {
            return true;
        } else {
            return false;
        }
    }

    function hashMessage(bytes32 message) private pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return keccak256(abi.encodePacked(prefix, message));
    }
}