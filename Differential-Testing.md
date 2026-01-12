# Differential Testing (also called Differential Fuzzing)

An advanced technique where you compare the output of your Solidity contract against a "reference model"—usually written in a high-level language like Python or JavaScript.
This is incredibly effective for DeFi protocols that use complex math (like bonding curves or interest rate models) where you need to ensure your Solidity implementation exactly matches a mathematical ideal.

## 1. How It Works: The FFI Cheatcode

Foundry uses a feature called FFI (Foreign Function Interface). This allows your Solidity tests to step "outside" the EVM, execute a script on your computer, and read the result back into the test.

The Workflow:

 * Foundry generates a random input (e.g., a deposit amount of 5,432.12).
 * It calls your Solidity function with that amount.
 * It uses vm.ffi() to call a Python script with the same amount.
 * It compares the two results. If they differ by even 1 wei, the test fails.

## 2. Setting Up the Reference Model (Python)

Create a simple script (e.g., math_model.py) that performs the "perfect" version of your math.
import sys
from eth_utils import to_hex, encode_abi

# Read input from Foundry (passed as command line arguments)
amount = int(sys.argv[1])
rate = 0.05  # 5% interest

# Calculate the "perfect" result
result = int(amount * rate)

# Return the result to Foundry as ABI-encoded bytes
print(to_hex(encode_abi(['uint256'], [result])))

3. The Solidity Differential Test
In your Foundry test file, you use the ffi cheatcode to run that Python script.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract DifferentialTest is Test {
    function test_MathAgainstPython(uint256 amount) public {
        // 1. Limit the input to a reasonable range for the model
        vm.assume(amount > 0 && amount < 1e30);

        // 2. Call the Python script
        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "scripts/math_model.py";
        inputs[2] = vm.toString(amount);

        bytes memory res = vm.ffi(inputs);
        uint256 pythonResult = abi.decode(res, (uint256));

        // 3. Call your Solidity contract
        uint256 solidityResult = myContract.calculateInterest(amount);

        // 4. Assert they match
        assertEq(solidityResult, pythonResult, "Solidity math mismatched Python model");
    }
}

4. Running the Test
Because FFI allows the execution of arbitrary shell commands, it is disabled by default for security. You must run it with the --ffi flag:
forge test --ffi --match-test test_MathAgainstPython
Why this is a 2026 Audit Requirement:
 * Catching Compiler Bugs: Sometimes the Solidity compiler itself has optimization bugs. Differential testing catches these because the Python model doesn't use the EVM.
 * Edge Case Discovery: Fuzzers are great at finding the exact 2^{256}-1 values that cause overflows which a human might never think to check.
 * Trustless Verification: It proves to your users (and auditors) that your "Code is Law" matches the "Math is Law" intended by the whitepaper.
Would you like me to show you how to handle cases where the results shouldn't be exactly equal (e.g., allowing for 1-2 wei of rounding error tolerance)?
The Power of Differential Testing
This video provides a practical explanation of how differential testing uncovers hidden bugs by comparing Solidity behavior across different frameworks and languages.

YouTube video views will be stored in your YouTube History, and your data will be stored and used by YouTube according to its Terms of Service
