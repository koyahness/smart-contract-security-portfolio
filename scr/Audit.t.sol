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
