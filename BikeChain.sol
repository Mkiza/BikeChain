// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

//Create a contract called BikeChain where you can add yourself as a renter
//and add a bike to the blockchain. You can also rent a bike and return a bike.
//You can also see the bikes that are available to rent and the bikes that are
//currently rented out.

//Create a contract called BikeChain

contract BikeChain {
    address owner;

    // Create a struct called Renter with the following properties: walletAddress
    //Add yourself as a renter
    constructor() {
        owner = msg.sender;
    }

    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint256 balance;
        uint256 start;
        uint256 end;
        uint256 due;
    }

    mapping(address => Renter) public renters;

    function addRenters(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        bool canRent,
        bool active,
        uint256 balance,
        uint256 start,
        uint256 due,
        uint256 end
    ) public {
        renters[walletAddress] = Renter(
            walletAddress,
            firstName,
            lastName,
            canRent,
            active,
            balance,
            start,
            due,
            end
        );
    }

    function checkOut(address walletAddress) public {
        require(renters[walletAddress].due == 0, "You have a balance due");
        require(
            renters[walletAddress].canRent == true,
            "You cannot rent a bike"
        );
        renters[walletAddress].canRent = false;
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        setDueAmount(walletAddress);
    }

    function checkIn(address walletAddress) public {
        require(
            renters[walletAddress].active == true,
            "Please check out a bike first"
        );
        renters[walletAddress].canRent = true;
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
    }

    function renterTimespan(uint256 start, uint256 end)
        internal
        pure
        returns (uint256)
    {
        return end - start;
    }

    function getTotalDuration(address walletAddress)
        public
        view
        returns (uint256)
    {
        require(
            renters[walletAddress].active == false,
            "Bike is currenlt checked out"
        );
        uint256 timespan = renterTimespan(
            renters[walletAddress].start,
            renters[walletAddress].end
        );
        uint256 timespanInMinutes = timespan / 60;
        return timespanInMinutes;
    }

    function getContractBalance(address walletAddress)
        public
        view
        returns (uint256)
    {
        return renters[walletAddress].balance;
    }

    function getRentersBalance(address walletAddress)
        public
        view
        returns (uint256)
    {
        return renters[walletAddress].balance;
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function setDueAmount(address walletAddress) internal {
        uint256 timespanMinutes = getTotalDuration(walletAddress);
        uint256 fiveMinutesIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinutesIncrements * 50000000000000000;
    }

    function canRentBike(address walletAddress) public view returns (bool) {
        return renters[walletAddress].canRent;
    }

    //Make payment function
    function makePayment(address walletAddress) public payable {
        require(
            renters[walletAddress].due > 0,
            "You do not have a balance due"
        );
        require(
            renters[walletAddress].balance > msg.value,
            "You do not have enough funds"
        );
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

    function deposit(address walletAddress) public payable {
        renters[walletAddress].balance += msg.value;
    }
}
