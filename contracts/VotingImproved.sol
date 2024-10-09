// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract VotingImproved {
    struct Proposal {
        bytes32 description;
        uint256 voteCount;
    }
    struct Voter {
        bool registered;
        bool voted;
    }

    address public immutable chairperson;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;
    uint256 public votingDeadlineBlock;

    event VoterRegistered(address indexed voterAddress);
    event VoteCast(address indexed voter, uint256 indexed choiceIndex);
    event ExtendedDeadline(uint256 newDeadlineBlock);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can do this");
        _;
    }

    modifier onlyDuringVoting() {
        require(block.number <= votingDeadlineBlock, "Voting has ended");
        _;
    }

    modifier onlyAfterVoting() {
        require(block.number > votingDeadlineBlock, "Voting not yet ended");
        _;
    }

    constructor(bytes32[] memory proposalNames, uint256 blockDuration) {
        require(proposalNames.length >= 2, "At least 2 proposals needed");
        require(!isProposalDuplicate(proposalNames), "Proposals cannot be duplicated");
        chairperson = msg.sender;
        votingDeadlineBlock = block.number + blockDuration;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({description: proposalNames[i], voteCount: 0}));
        }
    }

    function register(address voter) external onlyChairperson onlyDuringVoting {
        require(!voters[voter].registered, "Voter already registered");
        voters[voter] = Voter({registered: true, voted: false});
        emit VoterRegistered(voter);
    }

    function vote(uint256 proposal) external onlyDuringVoting {
        Voter storage sender = voters[msg.sender];
        require(sender.registered, "Voter is not registered");
        require(!sender.voted, "Already voted");
        require(proposal < proposals.length, "Invalid proposal");
        proposals[proposal].voteCount += 1;
        sender.voted = true;
        emit VoteCast(msg.sender, proposal);
    }

    function getWinningProposalIndex() private view onlyAfterVoting returns (uint256 winningProposalIndex) {
        uint256 winningVoteCount;
        winningProposalIndex = 0;
        uint256 proposalsLength = proposals.length;
        for (uint256 i = 0; i < proposalsLength; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }
    }

    function thereIsTie() private view onlyAfterVoting returns (bool) {
        uint256 winningVoteCount;
        uint256 votesAtTie;
        uint256 proposalsLength = proposals.length;
        for (uint256 i = 0; i < proposalsLength; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
            } else if (proposals[i].voteCount == winningVoteCount) {
                votesAtTie = winningVoteCount;
            }
        }
        return winningVoteCount == votesAtTie;
    }

    function winnerName() external view onlyAfterVoting returns (bytes32) {
        require(!thereIsTie(), "Tied result");
        return proposals[getWinningProposalIndex()].description;
    }

    function solveTie() external onlyAfterVoting { // maybe onlyChairperson ?
        require(thereIsTie(), "No tie, there is a winner");
        votingDeadlineBlock = block.number + 1000;
        emit ExtendedDeadline(votingDeadlineBlock);
    }

    function isProposalDuplicate(bytes32[] memory proposalNames) private pure returns (bool) {
        for (uint256 i = 0; i < proposalNames.length; i++) {
            for (uint256 j; j < i; j++) {
                if (proposalNames[i] == proposalNames[j]) {
                    return true;
                }
            }
        }
        return false;
    }
    
}