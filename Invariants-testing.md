In Foundry, Invariant Testing (also called "Stateful Fuzzing") is the gold standard for DeFi security. Unlike a unit test that checks one specific scenario, an invariant test tries to break a fundamental rule of your contract by calling random functions in a random order thousands of times.
Here is a sample setup for a basic Lending/Vault contract.
The Invariant Logic
We want to prove this rule: "The total assets held by the contract must always be greater than or equal to the sum of all individual user balances."
1. The "Handler" (The User Simulator)
First, we create a "Handler" contract. Think of this as a "bot" that knows how to interact with your protocol correctly but will try random amounts.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MyLendingVault } from "../src/MyLendingVault.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";

contract Handler {
    MyLendingVault public vault;
    MockERC20 public token;
    uint256 public ghost_totalSumOfBalances;

    constructor(MyLendingVault _vault, MockERC20 _token) {
        vault = _vault;
        token = _token;
    }

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(address(this)));
        if (amount == 0) return;

        token.approve(address(vault), amount);
        vault.deposit(amount);
        
        ghost_totalSumOfBalances += amount;
    }

    function withdraw(uint256 amount) public {
        uint256 userBal = vault.balanceOf(address(this));
        amount = bound(amount, 0, userBal);
        if (amount == 0) return;

        vault.withdraw(amount);
        ghost_totalSumOfBalances -= amount;
    }
}

2. The Invariant Test
This is the contract Foundry actually runs. It points the fuzzer at the Handler and defines the "invariant" (the truth that must never be broken).
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Handler } from "./Handler.sol";
import { MyLendingVault } from "../src/MyLendingVault.sol";

contract VaultInvariants is Test {
    MyLendingVault public vault;
    Handler public handler;

    function setUp() public {
        // ... Deployment logic ...
        handler = new Handler(vault, token);
        
        // Tell Foundry to target the handler's functions
        targetContract(address(handler));
    }

    // This property must ALWAYS hold true
    function invariant_solvency() public {
        uint256 totalAssets = token.balanceOf(address(vault));
        assertGe(totalAssets, handler.ghost_totalSumOfBalances());
    }
}

How to Run It
In your terminal, you would run:
forge test --match-test invariant_solvency
Foundry will then perform "Deep Actions":
 * Call deposit(500)
 * Call withdraw(100)
 * Call deposit(2)
 * ...repeat 10,000 times...
 * After every single call, it checks invariant_solvency. If the protocol has a rounding error or a reentrancy bug that leaks funds, the test will fail and show you the exact sequence of moves that broke it.
Would you like me to explain how to interpret the "Counterexample" Foundry provides when an invariant fails?
