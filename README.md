# Staking Farm - Upgradeable Yield Farming Contract

A comprehensive, upgradeable staking and yield farming smart contract system built with Foundry. This project implements a modern staking protocol with reward distribution, pause functionality, and upgradeable architecture.

## 🏗️ Architecture

The project consists of three main contracts:

- **TokenA** (`src/TokenA.sol`): Staking token (ERC20)
- **TokenB** (`src/TokenB.sol`): Reward token (ERC20)  
- **StakingFarm** (`src/StakingFarm.sol`): Main staking contract (Upgradeable)

### Upgradeable Design

The StakingFarm contract uses the UUPS (Universal Upgradeable Proxy Standard) pattern:
- **Implementation Contract**: Contains the business logic
- **Proxy Contract**: Stores state and delegates calls to implementation
- **Upgradeable**: Allows future upgrades while preserving user data

## 🚀 Features

### Core Functionality
- ✅ **Staking**: Users can stake TokenA to earn TokenB rewards
- ✅ **Reward Distribution**: Proportional rewards based on staked amount and time
- ✅ **Dynamic Reward Rates**: Owner can adjust reward rates
- ✅ **Reward Funding**: Contract can receive additional reward tokens
- ✅ **Emergency Controls**: Pause/unpause functionality
- ✅ **Reentrancy Protection**: Secure against reentrancy attacks

### Advanced Features
- ✅ **Upgradeable**: Future-proof architecture
- ✅ **Multi-user Support**: Multiple users can stake simultaneously
- ✅ **Accurate Reward Calculation**: Precise reward distribution
- ✅ **Emergency Withdrawal**: Withdraw staked tokens when paused
- ✅ **Comprehensive Testing**: Full test coverage

## 📋 Prerequisites

- [Foundry](https://getfoundry.sh/) (latest version)
- Git
- Node.js (for frontend, optional)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd staking-farm
   ```

2. **Install dependencies**
   ```bash
   forge install
   ```

3. **Build the project**
   ```bash
   forge build
   ```

## 🧪 Testing

### Run All Tests
```bash
forge test
```

### Run Specific Test
```bash
forge test --match-test test_Stake
```

### Run Tests with Verbose Output
```bash
forge test -vv
```

### Test Coverage
```bash
forge coverage
```

## 🚀 Deployment

### Local Development
```bash
# Start local node
anvil

# Deploy (in another terminal)
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Testnet/Mainnet Deployment
```bash
# Set environment variables
export PRIVATE_KEY=<your-private-key>
export RPC_URL=<your-rpc-url>

# Deploy
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

### Contract Upgrades
```bash
# Set proxy address
export PROXY_ADDRESS=<deployed-proxy-address>

# Upgrade
forge script script/Upgrade.s.sol --rpc-url $RPC_URL --broadcast
```

## 📊 Contract Functions

### User Functions
- `stake(uint256 amount)` - Stake tokens to earn rewards
- `withdraw(uint256 amount)` - Withdraw staked tokens
- `claimRewards()` - Claim accumulated rewards
- `exit()` - Withdraw all tokens and claim rewards
- `emergencyWithdraw()` - Emergency withdrawal when paused

### Admin Functions
- `setRewardRate(uint256 newRate)` - Update reward rate
- `pause()` / `unpause()` - Emergency pause controls
- `fundRewards(uint256 amount)` - Add reward tokens to contract
- `emergencyWithdrawTokens(address token, uint256 amount)` - Emergency token withdrawal

### View Functions
- `earned(address account)` - Get pending rewards for user
- `getStakerInfo(address account)` - Get user staking information
- `getAvailableRewards()` - Get contract's reward token balance
- `getTotalRewardsDistributed()` - Get total rewards distributed

## �� Configuration

### Reward Rate
- **Default**: 1 token per day per staked token
- **Adjustable**: Owner can change rate dynamically
- **Calculation**: `rewardRate = tokens_per_day / 86400` (per second)

### Token Configuration
- **Staking Token**: TokenA (ERC20)
- **Reward Token**: TokenB (ERC20)
- **Initial Supply**: 1,000,000 tokens each
- **Initial Funding**: 500,000 reward tokens to contract

## 📁 Project Structure

```
staking-farm/
├── src/
│   ├── TokenA.sol              # Staking token
│   ├── TokenB.sol              # Reward token
│   ├── StakingFarm.sol         # Main staking contract
│   └── StakingFarmProxy.sol    # Proxy contract
├── test/
│   └── Staking.t.sol           # Comprehensive test suite
├── script/
│   ├── Deploy.s.sol            # Deployment script
│   └── Upgrade.s.sol           # Upgrade script
├── frontend/                   # Web interface (optional)
├── foundry.toml               # Foundry configuration
└── README.md                  # This file
```

## 🔒 Security Features

- **Reentrancy Protection**: All external calls protected
- **Access Control**: Owner-only admin functions
- **Emergency Pause**: Circuit breaker pattern
- **Upgradeable**: Secure upgrade mechanism
- **Input Validation**: Comprehensive checks
- **Safe Math**: Built-in overflow protection (Solidity 0.8+)

## 🧪 Test Coverage

The project includes comprehensive tests covering:

- ✅ Contract deployment and initialization
- ✅ Staking and withdrawal functionality
- ✅ Reward calculation and distribution
- ✅ Multi-user scenarios
- ✅ Emergency functions
- ✅ Access control
- ✅ Upgrade functionality
- ✅ Edge cases and error conditions

## 🔄 Upgrade Process

### Before Upgrading
1. **Test thoroughly** on testnet
2. **Verify storage layout** compatibility
3. **Backup current state**
4. **Notify users** of upcoming changes

### Upgrade Steps
1. Deploy new implementation
2. Call `upgradeTo()` on proxy
3. Verify functionality
4. Update documentation

See [UPGRADEABLE_README.md](./UPGRADEABLE_README.md) for detailed upgrade guidelines.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions or issues:
- Open an issue on GitHub
- Check the [UPGRADEABLE_README.md](./UPGRADEABLE_README.md) for upgrade-specific questions
- Review the test files for usage examples

## 🔗 Links

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Ethereum Development](https://ethereum.org/developers/)
