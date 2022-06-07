//SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract Lottery{
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender;
        players.push(payable(manager));
    }

    receive() external payable{
        require(manager != msg.sender);
        require(msg.value == 1 ether);
        players.push(payable(msg.sender));
    }

    

    function getBalance() view public returns(uint){
        require(manager == msg.sender);
        return address(this).balance;
    }
    
    function random() view public returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function selectWinner() public view returns(address payable){
        // require(manager == msg.sender);
        require(players.length >= 10);

        uint rand = random();

        uint winnerIndex = rand % players.length;

        address payable winnerAddress = players[winnerIndex];
        return(winnerAddress);
    }

    function payWinner() public payable{
        require(manager == msg.sender);

        address payable winner = selectWinner();
        uint contractBalance = getBalance();

        uint winnerAmount = (90*contractBalance)/100;
        uint managerFees = contractBalance - winnerAmount;

        winner.transfer(winnerAmount);
        payable(manager).transfer(managerFees);

        players = new address payable[](0);
    }
}
