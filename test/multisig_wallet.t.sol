// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/multisig_wallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address constant USER1 = address(0x4);
    address user2 = address(0x5);
    address user3 = address(0x6);
    address user4 = address(0x7);

    function setUp() public {
        address[] memory signers = new address[](3);
        signers[0] = USER1;
        signers[1] = user2;
        signers[2] = user3;

        wallet = new MultiSigWallet(signers, 2);
    }

    function testSubmitTransaction() public {
        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");
        assertEq(wallet.getTransactionCount(), 1);
    }

    function testConfirmTransaction() public {
        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(user2);
        wallet.confirmTransaction(0);

        (, , , , uint256 confirmations) = wallet.transactions(0);
        assertEq(confirmations, 1);
    }

    function testRevokeConfirmation() public {
        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(user2);
        wallet.confirmTransaction(0);

        vm.prank(user2);
        wallet.revokeConfirmation(0);

        (, , , , uint256 confirmations) = wallet.transactions(0);
        assertEq(confirmations, 0);
    }

    function testExecuteTransaction() public {
        vm.deal(address(wallet), 1 ether);

        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(USER1);
        wallet.confirmTransaction(0);

        vm.prank(user2);
        wallet.confirmTransaction(0);

        uint256 balanceBefore = user4.balance;
        vm.prank(USER1);
        wallet.executeTransaction(0);

        (, , , bool executed, ) = wallet.transactions(0);
        assert(executed);
        assertEq(user4.balance, balanceBefore + 1 ether);
    }



    function testAddSigner() public {
        vm.prank(USER1);
        wallet.addSigner(user4);
        assert(wallet.isSigner(user4));
    }

    function testRemoveSigner() public {
        vm.prank(USER1);
        wallet.removeSigner(user3);
        assert(!wallet.isSigner(user3));
    }
}
