When an invariant fails, Foundry doesn't just say "False." It provides a Counterexample, which is essentially a play-by-play "exploit script" that proves your contract is vulnerable.
Reading these can be intimidating because they contain a lot of hex data and trace information. Here is how to break it down.
1. The Call Sequence
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
2. The Trace (The "How")
If you run your test with the -vvvv flag (four 'v's), Foundry provides a color-coded execution trace. This is where you see the "internal" failure.
 * Green: Successful calls.
 * Red: Reverted calls.
 * Yellow/Orange: Where the assert actually failed.
You can look for the specific line where totalAssets became less than ghost_totalSumOfBalances. Often, you'll see a small discrepancy (e.g., 1 wei) caused by a rounding error, or a large discrepancy caused by a logic flaw or access control bypass.
3. Interpreting Common Fails
When invariant_solvency fails, check these three usual suspects:
| Symptom | Likely Cause |
|---|---|
| Fail after 1-2 calls | High-level logic error or incorrect math formula in the contract. |
| Fail after 500+ calls | "Dust" accumulation. Small rounding errors that add up over time (e.g., 10 / 3 * 3 = 9). |
| Fail on "Withdraw" | An underflow/overflow error or an incorrect update to the totalAssets state variable. |
4. Using vm.label
To make the counterexample easier to read, you should label your addresses in your setUp:
vm.label(address(vault), "TheVault");
vm.label(address(token), "USDC");
vm.label(address(handler), "TheUserBot");

Now, instead of seeing 0x71091..., the counterexample will say TheUserBot.deposit(100), making it instantly clear who is doing what.
Would you like me to show you how to fix a common "Rounding Error" bug that these invariant tests often catch?
