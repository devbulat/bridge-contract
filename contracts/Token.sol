//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address private owner;
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner = msg.sender;
    }

    function mint(address user, uint amount) external {
        require(msg.sender == owner, "You are not an owner");
        _mint(user, amount);
    }

    function burn(address user, uint amount) external {
        require(msg.sender == owner, "You are not an owner");
        _burn(user, amount);
    }
}