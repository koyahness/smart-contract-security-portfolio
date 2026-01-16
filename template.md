# Audit Template

Below is a template you can use to populate your /audits folder.

**Audit Report**: Security evaluation of Protocol Name

**Date**: January 2026

**Auditor**: Koyahness

**Link to report**: https://

### Severity: 1 Critical, 2 Medium, 3 Low

## 1. Executive Summary

A brief overview of the protocol's purpose and the overall security posture discovered during the review.

## 2. Risk Classification

| Severity | Impact | Likelihood |
|---|---|---|
| Critical | Direct loss of all funds | High |
| High | Loss of some funds / Protocol bricked | Medium |
| Medium | Loss of yield / Temporary DoS | Medium |
| Low/Info | Gas optimizations / Best practices | N/A |

## 3. Vulnerability: Cross-Function Reentrancy [CRITICAL]
   
Description
The protocol manages user balances across two different contracts. While the withdrawal function uses a nonReentrant modifier, the internal accounting state is not updated until after the external call, allowing a "Cross-Function" attack.

Affected Code
```
// Vulnerable snippet in Vault.sol
function withdraw(uint256 amount) public {
    uint256 balance = balances[msg.sender];
    require(balance >= amount);
    
    (bool success, ) = msg.sender.call{value: amount}(""); // External Call
    require(success);
    
    balances[msg.sender] -= amount; // State update happens too late!
}
```
Recommendation

Implement the Checks-Effects-Interactions (CEI) pattern. Ensure all internal state updates occur before any external interaction.

## 4. Invariant Testing (Fuzzing) Results
   
To ensure the security of the fix, I utilized Foundry to run 10,000 runs of fuzz testing.

 * Invariant: totalAssets must always equal the sum of all individual userBalances.
   
 * Result: Passed (after fix).

## 💡 How to Add This to Your Portfolio

 * Create a Folder: Name it reports/ or audits/.
   
 * Use Markdown: Store reports as .md files so they render beautifully on GitHub.
   
 * Link it in your Main README: * [View Full Audit of Protocol X](./reports/protocol-x-report.md)

