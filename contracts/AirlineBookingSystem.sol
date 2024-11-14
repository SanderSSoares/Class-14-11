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

    function bookFlight(uint _flightId, uint _numberOfSeats) public payable {
        require(_flightId < flightCount, "Invalid FlightID");
        Flight storage flight = flights[_flightId];
        uint totalCost = flight.price*_numberOfSeats;
        require(msg.value == totalCost, "Incorrent payment amount");
        flight.bookedSeats += _numberOfSeats;
        ownerBalance += msg.value;
        emit FlightBooked(msg.sender, _flightId, _numberOfSeats, totalCost);
        emit PaymentReceived(msg.sender, msg.value);
    }

     // Function to cancel a booking
function cancelBooking(uint _flightId, uint _numberOfSeats) public payable {
    require(_flightId < flightCount, "Invalid flight ID.");
    Flight storage flight = flights[_flightId];
    require(flight.bookedSeats >= _numberOfSeats, "Not enough seats booked.");

    uint refundAmount = flight.price * _numberOfSeats;  // Calculate the refund amount.

    // Ensure the contract has enough funds to refund
    require(ownerBalance >= refundAmount, "Not enough balance in contract to refund.");

    // Refund the customer
    payable(msg.sender).transfer(refundAmount);  // Refund to the customer.

    // Update the booked seats and owner balance
    flight.bookedSeats -= _numberOfSeats;  // Decrease the number of booked seats.
    ownerBalance -= refundAmount;  // Decrease the airline balance by the refunded amount.

    emit FlightCancelled(msg.sender, _flightId, refundAmount);  // Log the cancellation.
}

    // Function to withdraw funds accumulated in the contract (Only owner can withdraw)
    function withdrawBalance() public onlyOwner {
        uint amount = ownerBalance;  // Get the accumulated balance of the contract.
        ownerBalance = 0;  // Reset the owner's balance to zero after withdrawal.
        payable(owner).transfer(amount);  // Transfer the accumulated balance to the owner's address (airline).
    }

    // Function to get the details of a specific flight (can be called by anyone)
    function getFlightDetails(uint _flightId) public view returns (string memory destination, uint price, uint bookedSeatsAvailable) {
        require(_flightId < flightCount, "Invalid flight ID.");  // Ensure the flight ID is valid.
        Flight memory flight = flights[_flightId];  // Get the flight details from the mapping.
        uint availableSeats = flight.totalSeats - flight.bookedSeats;  // Calculate the available seats by subtracting booked seats from total seats.
        return (flight.destination, flight.price, availableSeats);  // Return the flight destination, price, and available seats.
    }
}