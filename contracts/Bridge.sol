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
        uint256 nonce,
        bytes signature
    );

    event Redeem(
        address sender,
        address recipient, 
        uint256 amount, 
        uint256 chainFrom, 
        uint256 chainTo, 
        uint256 nonce,
        bytes signature
    );

    constructor(address tokenAddress, address validatorAddress) {
        validator = validatorAddress;
        token = Token(tokenAddress);
    }

    function swap(address recipient, uint256 amount, uint256 chainTo, uint256 nonce, bytes calldata signature) public  {
        require(swapNonces[msg.sender][nonce] == false, "Swap already in process");
        swapNonces[msg.sender][nonce] = true;
        token.burn(msg.sender, amount);
        uint256 chainFrom;
        
        assembly{
            chainFrom := chainid()
        }

        emit SwapInitialized(msg.sender, recipient, amount, chainFrom, chainTo, nonce, signature);
    }

    function redeem(address sender, address recipient, uint256 amount, uint256 chainFrom, uint256 chainTo, uint256 nonce, bytes calldata signature) public  {
        uint8 v;
        bytes32 r;
        bytes32 s;
        require(redeemNonces[sender][nonce] == false, "Redeem already in process");
        (v,r,s) = splitSignature(signature);
        require((checkSign(sender, amount, v, r, s)) == true, "Invalid signature");

        redeemNonces[sender][nonce] = true;
        token.mint(recipient, amount);

        emit Redeem(sender, recipient, amount, chainFrom, chainTo, nonce, signature);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32){
        require(sig.length == 65);
    
        bytes32 r;
        bytes32 s;
        uint8 v;
    
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    
        return (v, r, s);
    }


    function checkSign(address addr, uint256 val, uint8 v, bytes32 r, bytes32 s) public view returns (bool)  {
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