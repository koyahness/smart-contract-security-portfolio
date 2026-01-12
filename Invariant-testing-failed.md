# Failed invariant

When an invariant fails, Foundry doesn't just say "False." It provides a Counterexample, which is essentially a play-by-play "exploit script" that proves your contract is vulnerable.

Reading these can be intimidating because they contain a lot of hex data and trace information. Here is how to break it down.

## 1. The Call Sequence

The most important part of the output is the list of calls. Foundry will show you the exact path it took to break the logic:

[FAIL] invariant_solvency() (runs: 256, calls: 1403)

Counterexample:
  handler.deposit(1000000000000000000 [1e18])
  handler.withdraw(1)
  handler.deposit(1)
  ...

 * Runs: How many random "start-overs" it did.
 * Calls: How many function calls it made within that run before the math failed.
 * The "Minimal" Sequence: Foundry uses a process called Shrinking. If it finds a bug after 1,000 calls, it tries to delete unnecessary calls to give you the shortest possible list of actions that still triggers the bug.


## 2. The Trace (The "How")


If you run your test with the -vvvv flag (four 'v's), Foundry provides a color-coded execution trace. This is where you see the "internal" failure.

 * Green: Successful calls.
 * Red: Reverted calls.
 * Yellow/Orange: Where the assert actually failed.

You can look for the specific line where totalAssets became less than ghost_totalSumOfBalances.

Often, you'll see a small discrepancy (e.g., 1 wei) caused by a rounding error, or a large discrepancy caused by a logic flaw or access control bypass.


## 3. Interpreting Common Fails

When invariant_solvency fails, check these three usual suspects:

| Symptom | Likely Cause |
|---|---|
| Fail after 1-2 calls | High-level logic error or incorrect math formula in the contract. |
| Fail after 500+ calls | "Dust" accumulation. Small rounding errors that add up over time (e.g., 10 / 3 * 3 = 9). |
| Fail on "Withdraw" | An underflow/overflow error or an incorrect update to the totalAssets state variable. |

## 4. Using vm.label

To make the counterexample easier to read, you should label your addresses in your setUp:

vm.label(address(vault), "TheVault");
vm.label(address(token), "USDC");
vm.label(address(handler), "TheUserBot");

Now, instead of seeing 0x71091..., the counterexample will say TheUserBot.deposit(100), making it instantly clear who is doing what.

# Rounding Errors

Rounding errors are the "silent killers" of DeFi.

Invariant tests usually catch them when the fuzzer discovers that by depositing and withdrawing repeatedly, a user can slowly "drain" the contract of a few wei each time.

## The Vulnerable Code (Division Before Multiplication)

In Solidity, there are no decimals. If you divide before you multiply, you lose the remainder (precision).

```
// ❌ BAD: Rounds down significantly
function calculateReward(uint256 amount) public view returns (uint256) {
    // If rate is 10.5%, expressed as 105 / 1000
    // amount = 9, rate = 105/1000 -> (9 / 1000) * 105 = 0 * 105 = 0
    return (amount / precision) * rate; 
}
```

The Fix: Multiply First
By rearranging the operations, you keep the precision as long as possible before the final division.

```
// ✅ GOOD: More precise
function calculateReward(uint256 amount) public view returns (uint256) {
    // (9 * 105) / 1000 = 945 / 1000 = 0 (still 0, but much closer to the edge)
    return (amount * rate) / precision;
}
```
Handling the "1 Wei" Problem
Even with multiplication first, the EVM always rounds down (truncates) toward zero. In a vault, if you calculate shares for a withdrawal and it rounds down, the user gets slightly less than they are owed. If it rounds up, the user gets more, and the protocol becomes insolvent.
1. Use OpenZeppelin’s Math Library
The safest way to fix this is to use a library that allows you to specify the Rounding Direction.
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract SecureVault {
    using Math for uint256;

    function convertToShares(uint256 assets) public view returns (uint256) {
        // Round DOWN when issuing shares (protects protocol)
        return assets.mulDiv(totalShares, totalAssets, Math.Rounding.Floor);
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        // Round DOWN when paying out assets (protects protocol)
        return shares.mulDiv(totalAssets, totalShares, Math.Rounding.Floor);
    }
}

2. The "Favor the Protocol" Rule
 * When taking from the user: Round UP. (Ensure they pay enough).
 * When giving to the user: Round DOWN. (Ensure the protocol doesn't overpay).
How the Invariant Test Confirms the Fix
Once you apply Math.Rounding.Floor to your withdrawal logic, run your Foundry invariant test again:
 * The fuzzer will try to withdraw 1 wei repeatedly.
 * Because you are rounding down, the user will receive 0 tokens for their 1 share (if the math results in 0.999).
 * The totalAssets in the vault will remain \ge the ghost_totalSumOfBalances.
 * The test passes!
Would you like me to show you how to set up "Differential Testing," where we compare your contract's math against a known-perfect Python or JavaScript model?

