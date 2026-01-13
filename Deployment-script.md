# Deployment scripts

In Foundry, deployment scripts are not written in JavaScript or TypeScript. Instead, they are written in Solidity. This allows you to use the same logic, types, and helper functions you used in your smart contracts.
These scripts are executed by the Forge tool, which runs them locally to simulate the transactions before broadcasting them to the network.

## 🛠️ Anatomy of a Deployment Script

A standard script lives in the script/ directory and typically ends in .s.sol. It inherits from Script provided by the Forge Standard Library.
Here is a deployment script for the Vault contract we discussed earlier:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Vault.sol";

contract VaultScript is Script {
    function setUp() public {}

    function run() public {
        // 1. Retrieve the private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 2. Start broadcasting transactions to the network
        vm.startBroadcast(deployerPrivateKey);

        // 3. The actual deployment call
        Vault vault = new Vault();

        // 4. Stop broadcasting
        vm.stopBroadcast();
    }
}
```
## 🔍 Key Components Explained

### 1. vm.startBroadcast()
This is the most critical cheatcode for scripts.
 * Anything called after startBroadcast but before stopBroadcast is recorded as an on-chain transaction.
 * If you provide a private key, Forge will sign these transactions using that account.
 * If you don't provide a key, Forge will use a default sender (useful for local simulations).

### 2. Environment Variables
To keep your keys secure, Foundry uses .env files. You can load them into your script using vm.envUint("NAME") or vm.envAddress("NAME").

### 3. Execution vs. Broadcast

When you run the script, Foundry first simulates the execution locally. Only if the simulation succeeds and you provide the --broadcast flag will it actually send the transactions to the blockchain.

## 🚀 Running the Script

You use the forge script command to execute your deployment logic.

### A. Local Simulation (Dry Run)

This checks for errors without spending gas:

```
forge script script/Vault.s.sol:VaultScript --rpc-url <YOUR_RPC_URL>
```

### B. Actual Deployment

To send the transaction to a live network (like Sepolia or Mainnet):

``
forge script script/Vault.s.sol:VaultScript --rpc-url <YOUR_RPC_URL> --broadcast --verify -vvvv
```

 * --broadcast: Sends the transactions to the network.
 * --verify: Automatically attempts to verify the contract on Etherscan (requires an ETHERSCAN_API_KEY in your .env).
 * -vvvv: Shows the full execution trace so you can see exactly what happened during deployment.

## 📈 Post-Deployment: broadcast/ Folder

After a successful broadcast, Foundry creates a broadcast/ directory. Inside, you will find JSON files containing:
 * The address of the deployed contract.
 * The transaction hash.
 * The ABI and bytecode.
 * Details about the network and gas used.
This acts as a permanent record of your deployment, similar to Hardhat's "deployments" plugin.

## 💡 Pro Tip: Multi-Chain Deployment

Foundry makes it easy to deploy the same contract to multiple chains by simply changing the --rpc-url. Because the script is Solidity-based, you can even add logic to check block.chainid and deploy different configurations based on the network (e.g., using a different WETH address for Uniswap on Arbitrum vs. Mainnet).
