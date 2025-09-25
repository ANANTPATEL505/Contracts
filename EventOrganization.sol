// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
//Contract Address : 0xEaD40ff9e22F5E544559F64D0BC656b92Ab7423a

contract EventOrganization{

    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketSupply;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextID;

    function CreateEvent(string memory name,uint date,uint price,uint ticketSupply) public {
        require(date > block.timestamp, "Event date must be in the future");
        require(ticketSupply > 0, "Ticket supply must be greater than zero");

        events[nextID] = Event(msg.sender,name,date,price,ticketSupply,ticketSupply);
        nextID++;
    }

    function BuyTicket(uint id, uint quantity) external payable {
        Event storage thisevent = events[id];

        require(thisevent.date != 0, "Event does not exist");
        require(thisevent.date > block.timestamp, "Event has already ended");
        require(thisevent.ticketRemain >= quantity, "Not enough tickets left");
        require(msg.value == thisevent.price * quantity, "Incorrect payment amount");

        thisevent.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;

        payable(thisevent.organizer).transfer(msg.value);
    }

    function TransferTicket(address to, uint id, uint quantity) external {
        Event storage thisevent = events[id];

        require(thisevent.date != 0, "Event does not exist");
        require(thisevent.date > block.timestamp, "Event has already ended");
        require(tickets[msg.sender][id] >= quantity, "You don't own enough tickets");

        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }
}
