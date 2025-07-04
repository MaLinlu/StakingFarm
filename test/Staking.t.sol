// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {StakingFarm} from "../src/StakingFarm.sol";
import {StakingFarmProxy} from "../src/StakingFarmProxy.sol";

contract StakingTest is Test {
    TokenA public tokenA;
    TokenB public tokenB;
    StakingFarm public stakingFarm;
    
    address public owner;
    address public user1;
    address public user2;
    
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    uint256 public constant STAKE_AMOUNT = 1000 * 10**18;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        vm.startPrank(owner);
        
        // Deploy contracts
        tokenA = new TokenA();
        tokenB = new TokenB();
        
        // Deploy implementation and proxy
        StakingFarm implementation = new StakingFarm();
        bytes memory initData = abi.encodeWithSelector(
            StakingFarm.initialize.selector,
            address(tokenA),
            address(tokenB),
            owner
        );
        
        StakingFarmProxy proxy = new StakingFarmProxy(
            address(implementation),
            initData
        );
        
        stakingFarm = StakingFarm(address(proxy));
        
        // Mint tokens
        tokenA.mint(owner, INITIAL_SUPPLY);
        tokenB.mint(owner, INITIAL_SUPPLY);
        
        // Transfer reward tokens to staking farm
        tokenB.transfer(address(stakingFarm), 500000 * 10**18);
        
        vm.stopPrank();
        
        // Give users some tokens
        vm.prank(owner);
        tokenA.transfer(user1, STAKE_AMOUNT * 2);
        
        vm.prank(owner);
        tokenA.transfer(user2, STAKE_AMOUNT * 2);
    }

    function test_Deployment() public view {
        assertEq(address(stakingFarm.stakingToken()), address(tokenA));
        assertEq(address(stakingFarm.rewardToken()), address(tokenB));
        assertEq(stakingFarm.owner(), owner);
        assertEq(stakingFarm.totalStaked(), 0);
    }

    function test_Stake() public {
        vm.startPrank(user1);
        
        uint256 balanceBefore = tokenA.balanceOf(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        assertEq(stakingFarm.totalStaked(), STAKE_AMOUNT);
        assertEq(tokenA.balanceOf(user1), balanceBefore - STAKE_AMOUNT);
        
        (uint256 stakedAmount,,) = stakingFarm.getStakerInfo(user1);
        assertEq(stakedAmount, STAKE_AMOUNT);
        
        vm.stopPrank();
    }

    function test_StakeZeroAmount() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        
        vm.expectRevert("Cannot stake 0");
        stakingFarm.stake(0);
        
        vm.stopPrank();
    }

    function test_Withdraw() public {
        vm.startPrank(user1);
        
        // First stake
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        uint256 balanceBefore = tokenA.balanceOf(user1);
        
        // Then withdraw
        stakingFarm.withdraw(STAKE_AMOUNT / 2);
        
        assertEq(stakingFarm.totalStaked(), STAKE_AMOUNT / 2);
        assertEq(tokenA.balanceOf(user1), balanceBefore + STAKE_AMOUNT / 2);
        
        (uint256 stakedAmount,,) = stakingFarm.getStakerInfo(user1);
        assertEq(stakedAmount, STAKE_AMOUNT / 2);
        
        vm.stopPrank();
    }

    function test_WithdrawMoreThanStaked() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        vm.expectRevert("Insufficient staked amount");
        stakingFarm.withdraw(STAKE_AMOUNT + 1);
        
        vm.stopPrank();
    }

    function test_RewardsAccumulation() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        vm.stopPrank();
        
        // Fast forward time
        vm.warp(block.timestamp + 86400); // 1 day
        
        vm.prank(user1);
        uint256 earned = stakingFarm.earned(user1);
        assertGt(earned, 0, "Should have earned rewards");
    }

    function test_ClaimRewards() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        vm.stopPrank();
        
        // Fast forward time
        vm.warp(block.timestamp + 86400); // 1 day
        
        vm.startPrank(user1);
        
        uint256 balanceBefore = tokenB.balanceOf(user1);
        stakingFarm.claimRewards();
        
        uint256 balanceAfter = tokenB.balanceOf(user1);
        assertGt(balanceAfter, balanceBefore, "Should have received rewards");
        
        vm.stopPrank();
    }

    function test_Exit() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
                
        // Fast forward time
        vm.warp(block.timestamp + 86400); // 1 day
        
        
        uint256 tokenABalanceBefore = tokenA.balanceOf(user1);
        uint256 tokenBBalanceBefore = tokenB.balanceOf(user1);
        
        stakingFarm.exit();
        
        uint256 tokenABalanceAfter = tokenA.balanceOf(user1);
        uint256 tokenBBalanceAfter = tokenB.balanceOf(user1);
        
        assertEq(tokenABalanceAfter, tokenABalanceBefore + STAKE_AMOUNT, "Should have withdrawn staked tokens");
        assertGt(tokenBBalanceAfter, tokenBBalanceBefore, "Should have received rewards");
        assertEq(stakingFarm.totalStaked(), 0, "Total staked should be 0");
        
        vm.stopPrank();
    }

    function test_MultipleUsers() public {
        // User1 stakes
        vm.startPrank(user1);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        // User2 stakes
        vm.startPrank(user2);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        assertEq(stakingFarm.totalStaked(), STAKE_AMOUNT * 2);
        
        // Fast forward time
        vm.warp(block.timestamp + 86400); // 1 day
        
        // Both users should have earned rewards
        uint256 user1Earned = stakingFarm.earned(user1);
        uint256 user2Earned = stakingFarm.earned(user2);
        
        assertGt(user1Earned, 0, "User1 should have earned rewards");
        assertGt(user2Earned, 0, "User2 should have earned rewards");
        assertApproxEqRel(user1Earned, user2Earned, 0.01e18, "Both users should have similar rewards");
    }

    function test_PauseAndUnpause() public {
        vm.startPrank(owner);
        stakingFarm.pause();
        assertTrue(stakingFarm.paused());
        
        stakingFarm.unpause();
        assertFalse(stakingFarm.paused());
        vm.stopPrank();
    }

    function test_StakeWhenPaused() public {
        vm.prank(owner);
        stakingFarm.pause();
        
        vm.startPrank(user1);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        
        vm.expectRevert();
        stakingFarm.stake(STAKE_AMOUNT);
        
        vm.stopPrank();
    }

    function test_EmergencyWithdraw() public {
        vm.startPrank(user1);
        
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        
        vm.stopPrank();
        
        vm.prank(owner);
        stakingFarm.pause();
        
        vm.startPrank(user1);
        
        uint256 balanceBefore = tokenA.balanceOf(user1);
        stakingFarm.emergencyWithdraw();
        
        uint256 balanceAfter = tokenA.balanceOf(user1);
        assertEq(balanceAfter, balanceBefore + STAKE_AMOUNT, "Should have received staked tokens back");
        
        vm.stopPrank();
    }

    function test_OnlyOwnerFunctions() public {
        vm.startPrank(user1);
        
        vm.expectRevert();
        stakingFarm.setRewardRate(1e18);
        
        vm.expectRevert();
        stakingFarm.pause();
        
        vm.expectRevert();
        stakingFarm.emergencyWithdrawTokens(address(tokenA), 1000);
        
        vm.stopPrank();
    }

    function test_RewardRateUpdate() public {
        uint256 newRate = uint256(2e18) / 86400; // 2 tokens per day
        
        vm.prank(owner);
        stakingFarm.setRewardRate(newRate);
        
        assertEq(stakingFarm.rewardRate(), newRate);
    }

    function test_RewardRateUpdate_WhenStaked() public {
        vm.startPrank(user1);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();

        //Day 0: user1 stakes 1000 tokens staked, reward rate 1 token per day
        //Day 1: reward rate 2 tokens per day
        vm.warp(block.timestamp + 86400);
        uint256 newRate = uint256(2e18) / 86400; // 2 tokens per day

        vm.prank(owner);
        stakingFarm.setRewardRate(newRate);
        assertEq(stakingFarm.rewardRate(), newRate);

        //Day 2: reward rate 0.5 tokens per day
        vm.warp(block.timestamp + 86400);
        uint256 newRate2 = uint256(0.5e18) / 86400; // 0.5 tokens per day

        //Day2: user2 stakes 1000 tokens staked, reward rate 0.5 tokens per day
        vm.startPrank(user2);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();

        vm.prank(owner);
        stakingFarm.setRewardRate(newRate2);
        assertEq(stakingFarm.rewardRate(), newRate2);

        //Day3: user1 exit, claims rewards
        vm.warp(block.timestamp + 86400);
        vm.startPrank(user1);
        uint256 balanceBefore = tokenB.balanceOf(user1);
        stakingFarm.exit();
        uint256 balanceAfter = tokenB.balanceOf(user1);
        assertApproxEqRel(balanceAfter, balanceBefore + 3.25e18, 0.01e18, "User should have earned approximately 4 tokens");
        vm.stopPrank();

        //Day4: user2 claims rewards
        vm.warp(block.timestamp + 86400);
        vm.startPrank(user2);
        uint256 balanceBefore2 = tokenB.balanceOf(user2);
        stakingFarm.claimRewards();
        uint256 balanceAfter2 = tokenB.balanceOf(user2);
        assertApproxEqRel(balanceAfter2, balanceBefore2 + 0.75e18, 0.01e18, "User should have earned approximately 0.75 tokens");
    }

    function test_RewardFunding() public {
        uint256 initialBalance = tokenB.balanceOf(address(stakingFarm));
        uint256 fundAmount = 100000 * 10**18; // 100K tokens
        
        vm.startPrank(owner);
        tokenB.approve(address(stakingFarm), fundAmount);
        stakingFarm.fundRewards(fundAmount);
        vm.stopPrank();
        
        uint256 newBalance = tokenB.balanceOf(address(stakingFarm));
        assertEq(newBalance, initialBalance + fundAmount, "Contract should have received funded tokens");
    }

    function test_ClaimRewardsWithInsufficientFunds() public {
        // Stake some tokens
        vm.startPrank(user1);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        // Fast forward time to accumulate rewards
        vm.warp(block.timestamp + 86400); // 1 day
        
        // Remove all reward tokens from contract (must be done by owner)
        vm.startPrank(owner);
        uint256 contractBalance = tokenB.balanceOf(address(stakingFarm));
        stakingFarm.emergencyWithdrawTokens(address(tokenB), contractBalance);
        vm.stopPrank();
        
        // Try to claim rewards - should fail
        vm.startPrank(user1);
        vm.expectRevert("Insufficient reward tokens in contract");
        stakingFarm.claimRewards();
        vm.stopPrank();
    }

    function test_GetAvailableRewards() public view {
        uint256 availableRewards = stakingFarm.getAvailableRewards();
        assertEq(availableRewards, tokenB.balanceOf(address(stakingFarm)), "Should return correct available rewards");
    }

    function test_GetTotalRewardsDistributed() public {
        uint256 initialDistributed = stakingFarm.getTotalRewardsDistributed();
        assertEq(initialDistributed, 0, "Should start with 0 distributed rewards");
        
        // Stake and claim rewards
        vm.startPrank(user1);
        tokenA.approve(address(stakingFarm), STAKE_AMOUNT);
        stakingFarm.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        vm.warp(block.timestamp + 86400); // 1 day
        
        vm.startPrank(user1);
        stakingFarm.claimRewards();
        vm.stopPrank();
        
        uint256 finalDistributed = stakingFarm.getTotalRewardsDistributed();
        assertGt(finalDistributed, 0, "Should have distributed some rewards");
    }
} 