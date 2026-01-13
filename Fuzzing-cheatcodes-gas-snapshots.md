# Fuzzing, Cheatcodes and Gas snapshots

Solidity test file in Foundry. This example demonstrates a "Vault" contract and a corresponding test suite that utilizes Fuzzing, Cheatcodes, and Gas Snapshots.

## 1. The Target: Vault.sol

This simple contract allows users to deposit Ether and withdraw it later. It contains a basic security check to prevent unauthorized withdrawals.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vault {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
```

2. The Test: Vault.t.sol
This test file demonstrates how Foundry interacts with the code above.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address user = address(1);

    // Setup runs before every single test function
    function setUp() public {
        vault = new Vault();
    }

    // 1. Basic Unit Test with Cheatcodes
    function testDeposit() public {
        vm.deal(user, 10 ether); // Cheatcode: Give 'user' 10 ETH
        
        vm.prank(user);          // Cheatcode: Next call is from 'user'
        vault.deposit{value: 1 ether}();

        assertEq(vault.balances(user), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    // 2. Fuzz Test: Foundry tries random amounts
    function testFuzzDeposit(uint256 amount) public {
        // Assume: Tells the fuzzer to ignore unrealistic values
        vm.assume(amount > 0 && amount < 1e18); 
        
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        assertEq(vault.balances(user), amount);
    }

    // 3. Testing Reverts
    function testFailWithdrawInsufficient() public {
        vm.expectRevert("Insufficient balance"); // Expect the next call to fail
        vault.withdraw(1 ether);
    }
}

3. Understanding the "Trace" Output
When you run these tests using forge test -vvvv (the "v"s indicate verbosity), Foundry provides a high-fidelity execution trace. This is one of Foundry's most powerful features for debugging.
 * -v: Success/Failure summary.
 * -vv: Shows console.log outputs.
 * -vvv: Shows stack traces for failing tests.
 * -vvvv: Shows stack traces for all tests, including setup and successful calls.
 * -vvvvv: Shows full setup and storage traces.
4. Advanced: Fork Testing
Foundry allows you to "fork" a live network (like Ethereum Mainnet) into your local testing environment. This is invaluable for testing interactions with existing protocols like Uniswap or Aave.
Command:
forge test --fork-url <YOUR_RPC_URL>
In your code, you can even switch between different forks mid-test:
uint256 mainnetFork = vm.createFork("mainnet_url");
uint256 optimismFork = vm.createFork("optimism_url");

vm.selectFork(mainnetFork);
// Test something on Mainnet...

vm.selectFork(optimismFork);
// Test how it behaves on Optimism...

5. Summary of Workflow
 * forge init: Start a new project.
 * forge build: Compile (blazing fast).
 * forge test: Run unit, fuzz, and invariant tests.
 * forge snapshot: Check gas costs and compare changes.
 * forge script: Deploy to a network using Solidity.
 * cast: Interact with the deployed contract directly from the CLI.
Would you like to see how to write a Deployment Script in Solidity, or should we look at how to handle External Dependencies (libraries) using Forge?
