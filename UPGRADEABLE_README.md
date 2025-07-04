# Upgradeable StakingFarm Contract

This project now uses an upgradeable contract pattern for the StakingFarm contract, allowing for future upgrades while preserving user data and state.

## Architecture

The upgradeable pattern consists of:

1. **Implementation Contract** (`StakingFarm.sol`): Contains the actual logic
2. **Proxy Contract** (`StakingFarmProxy.sol`): Delegates calls to the implementation and stores state
3. **Storage**: All state variables are stored in the proxy contract

## Key Changes Made

### 1. Contract Inheritance
- Changed from regular OpenZeppelin contracts to upgradeable versions:
  - `Ownable` → `OwnableUpgradeable`
  - `ReentrancyGuard` → `ReentrancyGuardUpgradeable`
  - `Pausable` → `PausableUpgradeable`
- Added `Initializable` and `UUPSUpgradeable`

### 2. Constructor → Initializer
- Replaced constructor with `initialize()` function
- Added `_disableInitializers()` in constructor for security
- Added `_authorizeUpgrade()` function for upgrade authorization

### 3. State Variables
- Removed `immutable` keyword from token addresses
- All state variables are now stored in the proxy

## Deployment

### Initial Deployment
```bash
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast
```

This will deploy:
1. TokenA and TokenB contracts
2. StakingFarm implementation contract
3. StakingFarmProxy contract (with initialization)
4. Transfer initial tokens to the proxy

### Upgrading the Contract
```bash
# Set the proxy address
export PROXY_ADDRESS=<PROXY_ADDRESS>

# Run upgrade script
forge script script/Upgrade.s.sol --rpc-url <RPC_URL> --broadcast
```

## Security Considerations

1. **Initialization**: The `initialize()` function can only be called once
2. **Upgrade Authorization**: Only the owner can upgrade the contract
3. **Storage Layout**: Never change the order or types of existing state variables
4. **Implementation**: The implementation contract should never be used directly

## Testing

The test suite has been updated to work with the proxy pattern. All tests now deploy the implementation and proxy contracts before running.

## Important Notes

- **Never interact directly with the implementation contract**
- **Always use the proxy address for all interactions**
- **Preserve storage layout when upgrading**
- **Test upgrades thoroughly before deploying to mainnet**

## Storage Layout

The current storage layout (slot order):
1. `_initialized` (Initializable)
2. `_initializing` (Initializable)
3. `_owner` (OwnableUpgradeable)
4. `_status` (ReentrancyGuardUpgradeable)
5. `_paused` (PausableUpgradeable)
6. `_implementation` (UUPSUpgradeable)
7. `stakingToken` (IERC20)
8. `rewardToken` (IERC20)
9. `stakers` (mapping)
10. `totalStaked` (uint256)
11. `totalRewardsDistributed` (uint256)
12. `rewardRate` (uint256)
13. `lastUpdateTime` (uint256)
14. `rewardPerTokenStored` (uint256)

**⚠️ Warning**: Never change this storage layout in future upgrades!

## Adding New Features in Upgrades

### ✅ Safe: Adding New Functions
```solidity
// Always safe to add new functions
function emergencyPause() external onlyOwner {
    _pause();
}

function getStakerCount() external view returns (uint256) {
    // New view function
}
```

### ✅ Safe: Adding New State Variables (at the end)
```solidity
// Current storage layout (slots 12-14)
uint256 public rewardRate;
uint256 public lastUpdateTime;
uint256 public rewardPerTokenStored;

// Future upgrade - ADD THESE AT THE END
uint256 public emergencyPauseTime;        // Slot 15 (NEW)
mapping(address => uint256) public userLevel; // Slot 16 (NEW)
bool public whitelistEnabled;             // Slot 17 (NEW)
```

### ❌ Dangerous: Modifying Existing Storage Layout
```solidity
// NEVER DO THIS - it will corrupt existing data!
uint256 public rewardRate;
uint256 public newVariable;        // WRONG! Overwrites lastUpdateTime
uint256 public lastUpdateTime;     // WRONG! Overwrites rewardPerTokenStored
uint256 public rewardPerTokenStored; // WRONG! Data corruption!
```

## Best Practices for Upgrades

1. **Always add new state variables at the end**
2. **Never remove or reorder existing state variables**
3. **Never change variable types (uint256 → uint128 breaks compatibility)**
4. **Test upgrades thoroughly on testnet first**
5. **Use storage gaps for future flexibility** (advanced technique) 