// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract StakingFarm is 
    Initializable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable,
    UUPSUpgradeable 
{
    using SafeERC20 for IERC20;

    // Token contracts
    IERC20 public stakingToken; // TokenA
    IERC20 public rewardToken;  // TokenB

    // Staking info
    struct Staker {
        uint256 stakedAmount;
        uint256 lastRewardPerToken;
        uint256 accumulatedRewards;
    }

    mapping(address => Staker) public stakers;
    uint256 public totalStaked;
    uint256 public totalRewardsDistributed;

    // Reward parameters
    uint256 public rewardRate; // rewards per second
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);
    event RewardsFunded(address indexed funder, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _stakingToken,
        address _rewardToken,
        address _owner
    ) public initializer {
        __Ownable_init(_owner);
        __ReentrancyGuard_init();
        __Pausable_init();
        
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = uint256(1e18) / 86400; // 1 token per day per staked token
        lastUpdateTime = block.timestamp;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            stakers[account].accumulatedRewards = earned(account);
            stakers[account].lastRewardPerToken = rewardPerTokenStored;
        }
        _;
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        
        stakers[msg.sender].stakedAmount += amount;
        totalStaked += amount;
        
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        
        emit Staked(msg.sender, amount);
    }

    function _withdraw(uint256 amount) internal updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Insufficient staked amount");
        
        stakers[msg.sender].stakedAmount -= amount;
        totalStaked -= amount;
        
        stakingToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        _withdraw(amount);
    }

    function _claimRewards() internal updateReward(msg.sender) {
        uint256 reward = stakers[msg.sender].accumulatedRewards;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward tokens in contract");
        
        stakers[msg.sender].accumulatedRewards = 0;
        totalRewardsDistributed += reward;
        
        rewardToken.safeTransfer(msg.sender, reward);
        
        emit RewardsClaimed(msg.sender, reward);
    }

    function claimRewards() external nonReentrant {
        _claimRewards();
    }

    function exit() external nonReentrant {
        _claimRewards();
        _withdraw(stakers[msg.sender].stakedAmount);
    }

    // View functions
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (
            (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / totalStaked
        );
    }

    function earned(address account) public view returns (uint256) {
        return (
            stakers[account].stakedAmount * 
            (rewardPerToken() - stakers[account].lastRewardPerToken)
        ) / 1e18 + stakers[account].accumulatedRewards;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    function getStakerInfo(address account) external view returns (
        uint256 stakedAmount,
        uint256 accumulatedRewards,
        uint256 pendingRewards
    ) {
        Staker memory staker = stakers[account];
        return (
            staker.stakedAmount,
            staker.accumulatedRewards,
            earned(account)
        );
    }

    // Admin functions
    function setRewardRate(uint256 _rewardRate) external onlyOwner updateReward(msg.sender) {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw() external whenPaused {
        uint256 stakedAmount = stakers[msg.sender].stakedAmount;
        require(stakedAmount > 0, "No tokens staked");
        
        stakers[msg.sender].stakedAmount = 0;
        totalStaked -= stakedAmount;
        
        stakingToken.safeTransfer(msg.sender, stakedAmount);
        
        emit Withdrawn(msg.sender, stakedAmount);
    }

    // Reward funding functions
    function fundRewards(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardsFunded(msg.sender, amount);
    }
    
    function getAvailableRewards() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }
    
    function getTotalRewardsDistributed() external view returns (uint256) {
        return totalRewardsDistributed;
    }

    // Emergency functions
    function emergencyWithdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }
} 