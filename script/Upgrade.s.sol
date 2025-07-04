// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {StakingFarm} from "../src/StakingFarm.sol";

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get proxy address from environment or set it manually
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        StakingFarm newImplementation = new StakingFarm();
        console.log("New StakingFarm implementation deployed at:", address(newImplementation));

        // Upgrade the proxy
        StakingFarm proxy = StakingFarm(proxyAddress);
        proxy.upgradeToAndCall(address(newImplementation), "");
        
        console.log("Upgrade completed successfully!");
        console.log("New implementation:", address(newImplementation));
        console.log("Proxy address:", proxyAddress);

        vm.stopBroadcast();
    }
} 