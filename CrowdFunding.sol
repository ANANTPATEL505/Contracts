// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
//Contract Address : 0x3B22811C6664c785299a71941aBc2805C06Aae66

contract CrowdFunding {

    mapping(address => uint) public contributor;
    address public manager;
    uint public target;
    uint public deadline;
    uint public raisedAmount;
    uint public noOfContributors;
    uint public minimumContribution;

    struct Request {
        string description;
        uint amount;
        address payable recipient;
        bool complete;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public noOfRequest;

    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline; 
        minimumContribution = 100; 
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp <= deadline, "Deadline has passed");
        require(msg.value >= minimumContribution, "Minimum contribution is 100 wei = 0.0000000000000001 ETH");

        if (contributor[msg.sender] == 0) {
            noOfContributors++;
        }
        contributor[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target, "Not eligible for refund");
        require(contributor[msg.sender] > 0, "No contributions made");

        uint amount = contributor[msg.sender];
        contributor[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    modifier OnlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    function createRequest(string memory _description, uint _amount, address payable _recipient) public OnlyManager {
        Request storage newRequest = requests[noOfRequest];
        newRequest.description = _description;
        newRequest.amount = _amount; // already in wei
        newRequest.recipient = _recipient;
        newRequest.complete = false;
        newRequest.noOfVoters = 0;
        noOfRequest++;
    }

    function voteRequest(uint requestID) public {
        require(contributor[msg.sender] > 0, "Only contributors can vote");

        Request storage thisRequest = requests[requestID];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint requestID) public OnlyManager {
        require(raisedAmount >= target, "Target not reached");
        Request storage thisRequest = requests[requestID];
        require(thisRequest.complete == false, "Request already completed");
        require(thisRequest.noOfVoters > noOfContributors / 2, "Not enough votes");
        require(thisRequest.amount <= address(this).balance, "Not enough funds left");

        thisRequest.recipient.transfer(thisRequest.amount);
        thisRequest.complete = true;
    }
}

