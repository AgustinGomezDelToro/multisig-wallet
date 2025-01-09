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




    function testCannotConfirmAlreadyExecutedTransaction() public {
        vm.deal(address(wallet), 1 ether);

        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(USER1);
        wallet.confirmTransaction(0);

        vm.prank(user2);
        wallet.confirmTransaction(0);

        vm.prank(USER1);
        wallet.executeTransaction(0);

        vm.prank(USER1);
        vm.expectRevert("Transaction already executed");
        wallet.confirmTransaction(0);
    }

    function testCannotRevokeExecutedTransaction() public {
        vm.deal(address(wallet), 1 ether);

        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(USER1);
        wallet.confirmTransaction(0);

        vm.prank(user2);
        wallet.confirmTransaction(0);

        vm.prank(USER1);
        wallet.executeTransaction(0);

        vm.prank(USER1);
        vm.expectRevert("Transaction already executed");
        wallet.revokeConfirmation(0);
    }

    function testCannotSubmitTransactionIfNotSigner() public {
        vm.prank(user4);  // No es un signatario
        vm.expectRevert("Not a signer");
        wallet.submitTransaction(user4, 1 ether, "");
    }


    function testCannotConfirmTransactionTwice() public {
        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        vm.prank(USER1);
        wallet.confirmTransaction(0);

        vm.prank(USER1);
        vm.expectRevert("Already confirmed");
        wallet.confirmTransaction(0);
    }

    function testCannotConfirmNonExistentTransaction() public {
        vm.prank(USER1);
        vm.expectRevert("Transaction does not exist");
        wallet.confirmTransaction(99);
    }

    function testCannotRemoveSelfAsSigner() public {
        vm.prank(USER1);
        vm.expectRevert("Cannot remove yourself");
        wallet.removeSigner(USER1);
    }


    function testCannotExecuteWithInsufficientConfirmations() public {
        vm.deal(address(wallet), 1 ether);

        vm.prank(USER1);
        wallet.submitTransaction(user4, 1 ether, "");

        // Confirmación insuficiente, ya que solo un signatario confirmó la transacción
        vm.prank(USER1);
        wallet.confirmTransaction(0);

        // Se espera un error por confirmaciones insuficientes, no por no ser signatario
        vm.expectRevert("Not enough confirmations");
        wallet.executeTransaction(0);
    }


    function testCannotRemoveNonexistentSigner() public {
        address nonexistentSigner = address(0x9);
        vm.prank(USER1);
        vm.expectRevert("Not a signer");
        wallet.removeSigner(nonexistentSigner);
    }

    function testReceiveEther() public {
        uint256 initialBalance = address(wallet).balance;
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(wallet).call{value: 1 ether}("");
        assert(success);
        assertEq(address(wallet).balance, initialBalance + 1 ether);
    }

    function testAddExistingSigner() public {
        vm.prank(USER1);
        vm.expectRevert("Already a signer");
        wallet.addSigner(user2);
    }
}
