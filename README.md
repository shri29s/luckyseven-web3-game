# 🌰 LuckySeven - On-Chain Betting Game with ERC-20 Token

**LuckySeven** is a decentralized betting game where users wager the native in-game currency **LuckyCoin (LC)** against a random computer choice. The contract uses a capped ERC-20 token and includes dynamic exchange rates for buying/selling tokens with Ether.

---

## ⚙️ Contract Summary

* **Token**: `LuckyCoin (LC)`
* **Max Supply**: 1,000,000 LC
* **Initial Supply**: 100,000 LC to contract
* **Exchange Rates**: Dynamic `buy/sell` exchange rate system
* **Game Type**: Choose `< 7`, `== 7`, or `> 7` and win double LC if correct
* **Randomness**: Pseudo-random (can be upgraded to Chainlink VRF)
* **Security**: OpenZeppelin-based, includes `Ownable` and `ReentrancyGuard`

---

## ⚖️ Features

### 🎮 Gameplay (`play()`)

* Users choose one of:

  * `l7` (less than 7)
  * `e7` (exactly 7)
  * `g7` (greater than 7)
* If user’s guess matches randomly generated number:

  * They win 2x their LC bet
* Game outcomes are recorded in `gameHistory`

### 💰 LuckyCoin (LC) Economy

* ERC-20 capped at 1 million tokens
* Buy LC using ETH via `buyLuckyCoin()`
* Sell LC for ETH via `sellLuckyCoin()`
* Exchange rate adjusts after every buy/sell to simulate market pressure

### 🔧 Admin Controls

* `mintLC(address, amount)` - mint LC (up to cap)
* `setExchangeRates(buy, sell)` - update buy/sell price
* `withdrawEthers(amount)` - withdraw ETH from contract
* `withdrawTokens(amount)` - withdraw LC from contract
* `loadEthers()` - fund the contract

---

## 🔒 Security

* **ReentrancyGuard** used on critical functions
* **Ownable** functions restricted to contract owner
* **ERC20Capped** prevents over-minting
* Exchange rate moves in small steps to prevent drastic price shifts
* **Still uses pseudo-randomness**, not secure for real-value deployments — upgrade with [Chainlink VRF](https://docs.chain.link/docs/vrf/)

---

## 📦 Install & Compile

```bash
git clone https://github.com/shri29s/luckyseven-web3-game.git
cd luckyseven
forge install
forge build
```

---

## 🧪 Testing (Foundry)

Write test cases in `/test/`:

```bash
forge test
```

---

## 🧠 Example Usage

### Buy LC

```solidity
buyLuckyCoin(); // Send ETH to receive LC at current exchangeRateBuy
```

### Play Game

```solidity
play(Choice.e7, 100 * 10**18);
```

### Sell LC

```solidity
sellLuckyCoin(500 * 10**18); // Receive ETH based on exchangeRateSell
```

---

## 🚀 Deploy (optional)

Use Remix, Hardhat, or Foundry to deploy.

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

---

## 📊 Future Upgrades

* ✅ Chainlink VRF for secure randomness
* 🏡 DAO-based LC governance
* 🌐 Uniswap integration for open trading
* 🎨 React-based frontend (ask for a template!)

---

## 📄 License

MIT License

---

## 🤝 Contributing

Pull requests are welcome! Fork the repo and submit your changes via PR.

---

## 👤 Author

* **Shri Charan R / shri29s**
* GitHub: [@shri29s](https://github.com/shri29s)
