// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LuckySeven is Ownable, ReentrancyGuard {
    uint constant minimumBet = 0.1 ether;
    enum Choice{l7, e7, g7}
    enum Result{win, lose}

    event GameResult(Choice userChoice, Choice computerChoice, Result final_result);

    struct GameData {
        address user;
        Choice userChoice;
        Choice computerChoice;
        Result result;
    }
    mapping(address=>GameData[]) public gameHistory;

    constructor() payable ReentrancyGuard() Ownable(msg.sender) {
        require(msg.value > 0, "Send some ethers please...");
    }

    function play(Choice userChoice) external payable nonReentrant {
        require(msg.value >= minimumBet, "Insufficient funds");
        require(uint(userChoice) <= uint(Choice.g7), "Invalid choice");
        require(address(this).balance >= 2 * msg.value, "Service is unavailable");

        uint computerChoice = uint(keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                tx.origin,
                msg.sender,
                address(this).balance,
                gasleft()
            )
        )) % 14 + 1;
        Choice computer;

        if(computerChoice < 7) {computer = Choice.l7; }
        else if(computerChoice == 7) {computer = Choice.e7; }
        else {computer = Choice.g7; }

        if(computer == userChoice) {
            (bool success, ) = payable(msg.sender).call{value: 2 * msg.value}("");
            require(success, "Failed to send eth");
            emit GameResult(userChoice, computer, Result.win);

            gameHistory[msg.sender].push(GameData(msg.sender, userChoice, computer, Result.win));
        }else {
            emit GameResult(userChoice, computer, Result.lose);
            gameHistory[msg.sender].push(GameData(msg.sender, userChoice, computer, Result.lose));
        }
    }

    function getUserHistory(address user) public view returns (GameData[] memory) {
        return gameHistory[user];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }   

    function withdrawEthers() external nonReentrant {
        require(msg.sender == owner(), "You are not authenticated");
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Failed to send ether.");
    }

    function loadEthers() public payable {}

    receive() external payable { }
    fallback() external payable { }
}