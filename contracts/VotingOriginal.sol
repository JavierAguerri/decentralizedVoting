// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingOriginal {
    struct Proposal {
        string description;
        uint256 voteCount;
    }
    struct Voter {
        bool registered;
        bool voted;
        uint256 voteIndex;
    }
    address public chairperson;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this function");
        _;
    }
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({description: proposalNames[i], voteCount: 0}));
        }
    }
    function register(address voter) public onlyChairperson {
        require(!voters[voter].registered, "Voter already registered");
        voters[voter] = Voter({registered: true, voted: false, voteIndex: 0});
    }
    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.registered, "Voter is not registered");
        require(!sender.voted, "Already voted");
        require(proposal < proposals.length, "Invalid proposal");
        sender.voteIndex = proposal;
        proposals[proposal].voteCount += 1;
        sender.voted = true;
    }
    function winningProposal() public view returns (uint256 winningProposalIndex) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount >= winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }
    }
    function winnerName() public view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].description;
    }
}