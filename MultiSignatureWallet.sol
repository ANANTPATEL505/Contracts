// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract EventContract {
    address[] public owners;
    uint public noOfConfirmationR;

    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _noOfConfirmationR) {
        require(_owners.length > 0, "At least 1 owner required");
        require(_noOfConfirmationR > 0 && _noOfConfirmationR <= _owners.length, "Invalid confirmations required");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }

        noOfConfirmationR = _noOfConfirmationR;
    }

    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid recipient");
        require(msg.value > 0, "Value must be greater than 0");

        transactions.push(Transaction({
            to: _to,
            value: msg.value,
            executed: false
        }));
    }

    function confirmTransaction(uint _transactionID) public {
        require(_transactionID < transactions.length, "Invalid tx id");
        require(!transactions[_transactionID].executed, "Already executed");
        require(!isConfirmed[_transactionID][msg.sender], "Already confirmed");

        isConfirmed[_transactionID][msg.sender] = true;

        if (isTransactionConfirmed(_transactionID)) {
            executeTransaction(_transactionID);
        }
    }

    function executeTransaction(uint _transactionID) public payable {
        require(_transactionID < transactions.length, "Invalid tx id");
        require(!transactions[_transactionID].executed, "Already executed");
        require(isTransactionConfirmed(_transactionID), "Not enough confirmations");
        (bool success, ) = transactions[_transactionID].to.call{value: transactions[_transactionID].value}("");
        require(success, "Tx failed");

        transactions[_transactionID].executed = true;
    }

    function isTransactionConfirmed(uint _transactionID) public view returns (bool) {
        require(_transactionID < transactions.length, "Invalid tx id");
        uint confirmationCount;

        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionID][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount >= noOfConfirmationR;
    }
}

