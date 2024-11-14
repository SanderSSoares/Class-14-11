//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//Define Airline contract
contract Airline{

    address public owner;
    uint public ownerBalance;

    struct Flight{
        string destination;
        uint price;
        uint totalSeats;
        uint bookedSeats;
    }
    mapping (uint => Flight) public flights;
    uint public flightCount;

    event FlightAdded(uint flightId, string destination, uint price, uint totalSeats);
    event FlightBooked(address customer, uint flightId, uint numberOfSeats, uint totalCost);
    event PaymentReceived(address customer, uint amount);
    event FlightCancelled(address customer, uint flightId, uint refundedAmount);
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can perform this action");
        _;
    }

    constructor(){
        owner= msg.sender;
    }

    function addFlight(string memory _destination, uint _price, uint _totalSeats) public onlyOwner {
        flights[flightCount] = Flight(_destination, _price, _totalSeats, 0);
        emit FlightAdded(flightCount, _destination, _price, _totalSeats);
        flightCount++;
    }

    function bookFlight(uint _flightId, uint, _numberOfSeats) public payable {
        require(_flightId < flightCount, "Invalid FlightID");
        Flight storage flight = flights[_flightId];
    }
}