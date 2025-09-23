// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
//Contract Address : 0x56224337380C1987CD34002265D04BAd34fff83e
contract noob {
    
    address public manager;
    address payable[] public parti;

    constructor(){
        manager=msg.sender;
    }

    receive() external payable {
        require(msg.value>=0.0001 ether);
        parti.push(payable(msg.sender));
    }

    function get()public view returns(uint){
        require(msg.sender==manager);
        return address(this).balance;
    }

    function random()public view returns(uint){
        return uint(keccak256(abi.encode(block.prevrandao,block.timestamp,parti.length)));
    }

    function pick() public {
        require(msg.sender==manager, "Only manager can pick");
        require(parti.length >=3, "Need at least 3 players");
        address payable win;
        uint index=random()%parti.length;
        win=parti[index];
        win.transfer(get());
        parti=new address payable [](0);
    }

}
