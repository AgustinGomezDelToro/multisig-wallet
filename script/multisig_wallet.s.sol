// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/multisig_wallet.sol";

contract DeployMultisigWallet is Script {
    MultiSigWallet public wallet;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address[] memory signers = new address[](3);
        signers[0] = address(0x4);
        signers[1] = address(0x5);
        signers[2] = address(0x6);

        wallet = new MultiSigWallet(signers, 2);

        vm.stopBroadcast();
    }
}