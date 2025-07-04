// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {StakingFarm} from "../src/StakingFarm.sol";
import {StakingFarmProxy} from "../src/StakingFarmProxy.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy TokenA (Staking Token)
        TokenA tokenA = new TokenA();
        console.log("TokenA deployed at:", address(tokenA));

        // Deploy TokenB (Reward Token)
        TokenB tokenB = new TokenB();
        console.log("TokenB deployed at:", address(tokenB));

        // Deploy StakingFarm implementation
        StakingFarm stakingFarmImplementation = new StakingFarm();
        console.log("StakingFarm implementation deployed at:", address(stakingFarmImplementation));

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            StakingFarm.initialize.selector,
            address(tokenA),
            address(tokenB),
            deployer
        );

        // Deploy proxy
        StakingFarmProxy proxy = new StakingFarmProxy(
            address(stakingFarmImplementation),
            initData
        );
        console.log("StakingFarm proxy deployed at:", address(proxy));

        // Get the proxy contract instance
        StakingFarm stakingFarm = StakingFarm(address(proxy));

        // Mint initial tokens to deployer
        tokenA.mint(deployer, 1000000 * 10**18); // 1M tokens
        tokenB.mint(deployer, 1000000 * 10**18); // 1M tokens

        // Transfer some reward tokens to the staking farm
        tokenB.transfer(address(stakingFarm), 500000 * 10**18); // 500K tokens

        vm.stopBroadcast();

        console.log("Deployment completed successfully!");
        console.log("Deployer address:", deployer);
        console.log("TokenA (STK):", address(tokenA));
        console.log("TokenB (RWD):", address(tokenB));
        console.log("StakingFarm implementation:", address(stakingFarmImplementation));
        console.log("StakingFarm proxy:", address(proxy));
    }
} 