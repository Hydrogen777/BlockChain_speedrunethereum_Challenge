// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; 

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances; 
    uint256 public constant threshold = 1 ether;

    uint256 public deadline = block.timestamp + 72 hours;

    bool public openForWithdraw = false;

    event Stake(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    function stake() public payable {
        require(block.timestamp < deadline, "Da het thoi gian stake");
        
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        require(block.timestamp >= deadline, "Chua den thoi han deadline");
        require(!openForWithdraw, "Da mo cong rut tien roi");
        
        require(!exampleExternalContract.completed(), "Staking da hoan thanh");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public {
        require(openForWithdraw, "Chua duoc phep rut tien");
        
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Ban khong co so du");

        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Rut tien that bai");
        
        emit Withdraw(msg.sender, amount);
    }
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
    
    function metThreshold() public view returns (bool) {
        return address(this).balance >= threshold;
    }
    receive() external payable {
        stake();
    }
}