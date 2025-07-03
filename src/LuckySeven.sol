// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LuckySeven is Ownable, ReentrancyGuard, ERC20Capped {
    uint public constant minimumBet = 0.1 ether;
    uint public exchangeRateBuy = 1000;  // 1 ETH = 1000 LC
    uint public exchangeRateSell = 1000; // 1000 LC = 1 ETH

    enum Choice { l7, e7, g7 }
    enum Result { win, lose }

    event GameResult(address indexed user, Choice userChoice, Choice computerChoice, Result finalResult);
    event TokenPurchased(address indexed user, uint ethSent, uint tokensReceived);
    event TokenSold(address indexed user, uint tokensSold, uint ethReceived);

    struct GameData {
        Choice userChoice;
        Choice computerChoice;
        Result result;
    }

    mapping(address => GameData[]) public gameHistory;

    constructor() 
        ERC20("LuckyCoin", "LC")
        ERC20Capped(1_000_000 * 10 ** decimals()) 
        Ownable(msg.sender) 
    {
        _mint(address(this), 100_000 * 10 ** decimals()); // Initial liquidity
    }

    function play(Choice userChoice, uint amount) external nonReentrant {
        require(amount >= minimumBet, "Bet below minimum");
        require(uint8(userChoice) <= uint8(Choice.g7), "Invalid choice");
        require(balanceOf(msg.sender) >= amount, "Insufficient LC balance");
        require(balanceOf(address(this)) >= amount * 2, "Insufficient contract LC");

        uint rand = uint(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))
        ) % 12 + 1;

        Choice computer;
        if (rand < 7) computer = Choice.l7;
        else if (rand == 7) computer = Choice.e7;
        else computer = Choice.g7;

        if (computer == userChoice) {
            // User wins, gets double their bet
            _transfer(address(this), msg.sender, amount);
            gameHistory[msg.sender].push(GameData(userChoice, computer, Result.win));
            emit GameResult(msg.sender, userChoice, computer, Result.win);
        } else {
            // User loses, sends tokens to contract
            _transfer(msg.sender, address(this), amount);
            gameHistory[msg.sender].push(GameData(userChoice, computer, Result.lose));
            emit GameResult(msg.sender, userChoice, computer, Result.lose);
        }
    }

    function getUserHistory(address user) external view returns (GameData[] memory) {
        return gameHistory[user];
    }

    // ============ EXCHANGE ============

    function buyLuckyCoin() external payable nonReentrant {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint amount = msg.value * exchangeRateBuy;
        require(balanceOf(address(this)) >= amount, "Not enough tokens");

        _transfer(address(this), msg.sender, amount);
        emit TokenPurchased(msg.sender, msg.value, amount);

        // Increase exchange rate slightly
        exchangeRateBuy += 10;
        exchangeRateSell += 5;
    }

    function sellLuckyCoin(uint amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient LC");

        uint ethAmount = amount / exchangeRateSell;
        require(address(this).balance >= ethAmount, "Contract lacks ETH");

        _transfer(msg.sender, address(this), amount);
        payable(msg.sender).transfer(ethAmount);
        emit TokenSold(msg.sender, amount, ethAmount);

        // Decrease exchange rate slightly
        if (exchangeRateBuy > 10) exchangeRateBuy -= 10;
        if (exchangeRateSell > 5) exchangeRateSell -= 5;
    }

    function setExchangeRates(uint _buy, uint _sell) external onlyOwner {
        require(_buy > 0 && _sell > 0, "Rates must be > 0");
        exchangeRateBuy = _buy;
        exchangeRateSell = _sell;
    }

    // ============ ADMIN FUNCTIONS ============

    function loadEthers() external payable {}

    function withdrawEthers(uint amount) external onlyOwner nonReentrant {
        require(address(this).balance >= amount, "Insufficient ETH");
        payable(owner()).transfer(amount);
    }

    function withdrawTokens(uint amount) external onlyOwner {
        _transfer(address(this), owner(), amount);
    }

    function mintLC(address to, uint amount) external onlyOwner {
        _mint(to, amount); // ERC20Capped prevents exceeding cap
    }

    receive() external payable {}
    fallback() external payable {}
}
