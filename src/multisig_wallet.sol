// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title MultiSigWallet
/// @notice Un contrato de wallet multisig con al menos dos firmas requeridas para la ejecución de transacciones.
contract MultiSigWallet {
    address public constant USER1 = address(0x4);
    address[] public signers;
    uint256 public requiredConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(uint256 => mapping(address => bool)) public confirmations;
    Transaction[] public transactions;

    event Deposit(address indexed sender, uint256 value);
    event SubmitTransaction(address indexed sender, uint256 indexed txIndex);
    event ConfirmTransaction(address indexed signer, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed signer, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed signer, uint256 indexed txIndex);

    modifier onlySigner() {
        require(isSigner(msg.sender), "Not a signer");
        _;
    }

    constructor(address[] memory _signers, uint256 _requiredConfirmations) {
        require(_signers.length >= 3, "At least 3 signers required");
        require(_requiredConfirmations > 1 && _requiredConfirmations <= _signers.length, "Invalid confirmations");
        signers = _signers;
        requiredConfirmations = _requiredConfirmations;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint256 _value, bytes memory _data) public onlySigner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmations: 0
        }));

        emit SubmitTransaction(msg.sender, transactions.length - 1);
    }

    function confirmTransaction(uint256 _txIndex) public onlySigner {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        require(!confirmations[_txIndex][msg.sender], "Already confirmed");

        confirmations[_txIndex][msg.sender] = true;
        transactions[_txIndex].confirmations++;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex) public onlySigner {
        require(confirmations[_txIndex][msg.sender], "Transaction not confirmed");
        require(!transactions[_txIndex].executed, "Transaction already executed");

        confirmations[_txIndex][msg.sender] = false;
        transactions[_txIndex].confirmations--;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex) public onlySigner {
        require(transactions[_txIndex].confirmations >= requiredConfirmations, "Not enough confirmations");
        require(!transactions[_txIndex].executed, "Transaction already executed");

        Transaction storage txn = transactions[_txIndex];
        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function isSigner(address _account) public view returns (bool) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == _account) {
                return true;
            }
        }
        return false;
    }

    function addSigner(address _newSigner) public onlySigner {
        require(!isSigner(_newSigner), "Already a signer");
        signers.push(_newSigner);
    }

    function removeSigner(address _signerToRemove) public onlySigner {
        require(signers.length > 3, "Minimum 3 signers required");
        require(isSigner(_signerToRemove), "Not a signer");

        uint256 index;
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == _signerToRemove) {
                index = i;
                break;
            }
        }

        signers[index] = signers[signers.length - 1];
        signers.pop();
    }

    function getSigners() public view returns (address[] memory) {
        return signers;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }
}
