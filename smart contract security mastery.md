# Smart Contract Security Mastery

This repository serves as a comprehensive guide and laboratory for understanding, identifying, and mitigating common vulnerabilities in Solidity smart contracts.

## 🛡️ Project Overview

Security in Web3 is non-negotiable. Unlike traditional software, smart contract code is often immutable and manages direct financial value. This project demonstrates the "Attack and Defend" methodology:

 * The Vulnerability: Identifying the flaw in a "Broken" contract.

 * The Exploit: Crafting a malicious contract to trigger the flaw.

 * The Fix: Implementing best practices to secure the code.

## 🔍 Common Vulnerabilities Covered

1. Reentrancy

The most famous vulnerability (responsible for the DAO hack). It occurs when a contract calls an external address before updating its internal state.

 * Vulnerability: Using call.value() before updating the user balance.
   
 * Fix: Use the Checks-Effects-Interactions pattern or a ReentrancyGuard.
   
2. Integer Overflow/Underflow

Occurs when an arithmetic operation exceeds the maximum or minimum size of a type (relevant for Solidity versions < 0.8.0).

 * Vulnerability: A user with a balance of 0 subtracts 1, resulting in a massive positive balance.
 * Fix: Use Solidity 0.8+ or the OpenZeppelin SafeMath library.

3. Logic & Access Control

Errors in how permissions are handled, allowing unauthorized users to perform sensitive actions.

 * Vulnerability: Forgetting to add onlyOwner modifiers to withdraw() functions.
  
 * Fix: Strict use of OpenZeppelin’s Ownable or AccessControl.

## 🛠️ Security Audit Checklist

Before deploying any contract, ensure the following checks are met:

| Check | Description | Status |
|---|---|---|
| Visibility | Are functions correctly marked private, internal, or external? | □ |
| Pull over Push | Are you favoring user-triggered withdrawals over automated transfers? | □ |
| Gas Limits | Could any loops exceed the block gas limit (DoS)? | □ |
| Timestamp Dependency | Is the logic reliant on block.timestamp (which can be manipulated)? | □ |

🚀 How to Use This Repo
Prerequisites

 * Foundry or Hardhat
 * Basic knowledge of Solidity

Installation

git clone https://github.com/your-username/smart-contract-security.git

cd smart-contract-security

forge install

Running Tests

To simulate the attacks and verify the fixes:

forge test --match-path test/Reentrancy.t.sol -vvvv

💡 Best Practices

> "Code for the worst-case scenario."

> Always assume that external calls will fail, that users will try to break your logic, and that the blockchain environment is adversarial.

 * Keep it Simple: Complexity is the enemy of security.
 * Use Proven Libraries: Don't reinvent the wheel; use OpenZeppelin for standard implementations.
 * Audit Early: Use static analysis tools like Slither and Aderyn during development.
