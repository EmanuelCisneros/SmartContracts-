// pragma solidity ^0.8.26;

contract Auction {
    struct Bid {
        address bidder;
        uint amount;
    }

    address public owner;
    string public item;
    uint public auctionEndTime;
    bool public ended;

    Bid public highestBid;
    mapping(address => uint) public pendingReturns;

    event AuctionStarted(string item, uint endTime);
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier auctionOngoing() {
        require(block.timestamp < auctionEndTime, "Auction already ended");
        _;
    }

    modifier auctionEnded() {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction end already called");
        _;
    }

    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
        emit AuctionStarted(_item, auctionEndTime);
    }

    function bid() public payable auctionOngoing {
        require(msg.value > highestBid.amount, "There already is a higher bid");

        if (highestBid.amount != 0) {
            pendingReturns[highestBid.bidder] += highestBid.amount;
        }

        highestBid = Bid({
            bidder: msg.sender,
            amount: msg.value
        });

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function endAuction() public onlyOwner auctionEnded {
        ended = true;
        emit AuctionEnded(highestBid.bidder, highestBid.amount);

        payable(owner).transfer(highestBid.amount);
    }
}
