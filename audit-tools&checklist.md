# Audit tools for smart contracts

Solidity smart contract security auditing has evolved into a multi-layered process.

While automated tools are more powerful than ever—now frequently augmented by AI—the industry consensus remains that they are a "first line of defense" designed to support, not replace, manual expert review.

The modern security stack is generally categorized into five functional areas:


## 1. Static Analysis (The "First Pass")
   
These tools scan code without executing it. They are excellent for catching known vulnerability patterns (like reentrancy or integer overflows) and checking for adherence to best practices.

 * Slither: The industry standard. It converts Solidity into an intermediate representation (Slir) to run over 90+ detectors. In 2026, it is frequently used in CI/CD pipelines to catch "low-hanging fruit" during development.
   
 * Aderyn: A Rust-based static analyzer that has gained significant traction for its speed and its ability to output detailed, auditor-friendly reports in Markdown.

 * Mythril: Uses symbolic execution and SMT solving to find complex security bugs. It is "deeper" than Slither but slower.

 * Solhint: An essential linter for security and style, ensuring the code follows the Solidity Style Guide and common security patterns.

## 2. Dynamic Analysis & Fuzzing

Fuzzing involves bombarding the contract with thousands of random or semi-random inputs to find "edge cases" where the contract logic breaks.

 * Foundry (Forge Fuzz): The most popular developer-centric fuzzer. It allows you to write "property-based tests" in Solidity itself.
  
 * Echidna: A sophisticated property-based fuzzer. It is powerful for finding deep logical flaws but requires writing specific "invariants" (properties that should always be true).
  
 * Medusa: A newer, high-performance fuzzer from Trail of Bits that is designed to be faster and more user-friendly than Echidna.

 * Diligence Fuzzing: A cloud-based fuzzing service (by ConsenSys) that offers massive compute power to explore contract states.

## 3. Formal Verification
   
This is the most rigorous form of security. It uses mathematical proofs to guarantee that a contract will behave exactly as intended under all possible conditions.

 * Certora Prover: The leading commercial tool. Developers write "specifications" in CVL (Certora Verification Language), and the tool mathematically proves if the code matches the spec.

 * Kontrol: A tool that combines the K Framework (formal semantics of the EVM) with Foundry, allowing developers to perform formal verification on their existing test suites.

 * Halmos: A symbolic testing tool for Foundry that effectively bridges the gap between unit testing and formal verification.

## 4. Visualizers & Documentation Tools

Auditors use these to map out complex inheritance structures and internal function calls, which is where many "logic bombs" hide.

 * Surya: Generates visual graphs of function calls and inheritance.
  
 * Solidity Visual Auditor (VS Code):

An extension that provides security-centric syntax highlighting and call-graph visualizations directly in the editor.

 * Solidity Metrics: Provides a bird’s-eye view of code complexity, highlighting "risk areas" (e.g., functions with high cyclomatic complexity).

## 5. The "Modern" 2026 Additions: AI & Collaborative Tools

 * AI-Augmented Scanners: Tools like Octane or Cyfrin’s AI tools now use Large Language Models (LLMs) to scan for "business logic" errors—vulnerabilities that static analyzers usually miss because they require an understanding of what the contract is trying to do.

 * Audit Contests (Sherlock, Code4rena): While not "software," these platforms are considered essential "tools" in a 2026 audit strategy, crowdsourcing the manual review process to hundreds of independent researchers.

#### Comparison Summary

| Tool Category | Best For | Typical Tool |
|---|---|---|
| Static Analysis | Speed, common bugs, CI/CD | Slither, Aderyn |
| Fuzzing | Finding edge cases, unexpected state | Foundry, Echidna |
| Formal Verification | Mathematical certainty of logic | Certora, Kontrol |
| Visualization | Understanding complex architectures | Surya, Solidity Metrics |



# Audit checklist

The complexity of DeFi protocols (lending, yield farming, or liquid staking) requires a much more robust checklist than simple NFT drops.

Below is a professional-grade audit checklist tailored for a high-stakes DeFi protocol.

## Phase 1: Pre-Audit & Documentation

 * [ ] Technical Specification: Does the project have a document explaining the intended logic? (e.g., "If A deposits X, they should earn Y interest per block.")
 * [ ] Invariant Definitions: Have you listed properties that must always be true? (e.g., "The total debt in the system must never exceed the total collateral value.")
 * [ ] Test Coverage: Is there >95% branch coverage? Do tests include "unhappy paths" (expected reverts)?


## Phase 2: Logic & Architecture (The "Deep Dive")

 * [ ] Reentrancy (Cross-Contract): Are you using the nonReentrant modifier? More importantly, are you following the Checks-Effects-Interactions pattern?
 * [ ] Oracle Security: * Are you using a decentralized oracle (Chainlink/Pyth)?
   * Is there a "circuit breaker" if the oracle stops updating or returns a price of zero?
   * Are you protected against L2 Sequencer downtime?
 * [ ] Flash Loan Resistance: Can a massive infusion of capital manipulate your internal price calculations or reward distributions? (Always use Oracles for pricing, never internal pool balances).
 * [ ] Precision & Rounding: Are you performing multiplications before divisions? Does rounding favor the protocol rather than the user (to prevent "dust" drainage)?
 * [ ] Access Control: Are sensitive functions (e.g., setFee, emergencyWithdraw) protected by Ownable2Step or a Multi-sig?
Phase 3: Economic & Regulatory (The 2026 Standard)
 * [ ] Governance Risk: If your DAO token is concentrated, can a "whale" pass a malicious proposal to drain the treasury? (Consider Timelocks).
 * [ ] Slippage & MEV: Are there minimum output parameters (amountOutMin) on all swaps to prevent sandwich attacks?
 * [ ] 2026 Compliance Readiness: * Does the contract support blacklisting (for AML/Sanctions compliance)?
   * Are there hooks to integrate with Travel Rule data providers if required by your jurisdiction?
 * [ ] Upgradeability: If using Proxies (UUPS/Transparent), is the storage layout validated to prevent collisions during the next upgrade?
Phase 4: Automated Tooling Suite
Run these tools and clear all "High" and "Medium" findings before the human audit:
| Tool | Focus Area | Action |
|---|---|---|
| Slither | Static Analysis | Scan for tx.origin, uninitialized proxies, and reentrancy. |
| Aderyn | Static Analysis | Generate a quick Markdown report of common Solidity 0.8+ pitfalls. |
| Foundry Fuzz | Input Testing | Run 10,000+ runs on your deposit and withdraw functions. |
| Halmos | Formal Verification | Prove that your "Total Supply" invariant cannot be broken. |
Pro-Tip for 2026
Most top-tier auditors now expect an Invariants Suite. Instead of just testing "if I deposit 10, I get 10," you should have a test that runs forever trying to find any sequence of actions that makes the protocol insolvent.
Would you like me to write a sample Foundry invariant test for a basic lending contract?

