// pragma solidity ^0.8.26;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint vote;
    }

    address public owner;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    bool public votingOpen;

    event CandidateAdded(string name);
    event Voted(address voter, uint candidate);
    event VotingStarted();
    event VotingEnded();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier votingIsOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(string memory name) public onlyOwner {
        candidates.push(Candidate({
            name: name,
            voteCount: 0
        }));
        emit CandidateAdded(name);
    }

    function startVoting() public onlyOwner {
        require(!votingOpen, "Voting is already open");
        votingOpen = true;
        emit VotingStarted();
    }

    function endVoting() public onlyOwner votingIsOpen {
        votingOpen = false;
        emit VotingEnded();
    }

    function vote(uint candidateIndex) public votingIsOpen {
        Voter storage sender = voters[msg.sender];
        require(!sender.hasVoted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        sender.hasVoted = true;
        sender.vote = candidateIndex;

        candidates[candidateIndex].voteCount += 1;
        emit Voted(msg.sender, candidateIndex);
    }

    function getWinner() public view returns (string memory winnerName) {
        require(!votingOpen, "Voting is still open");

        uint winningVoteCount = 0;
        uint winningCandidateIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        winnerName = candidates[winningCandidateIndex].name;
    }
}
