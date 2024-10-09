// SPDX-License-Identifier: MIT
import "../.deps/npm/@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity ^0.8.26;

contract VotingImprovedBurning is ReentrancyGuard {
    struct Proposal {
        bytes32 description;
        uint256 voteCount;
    }

    address public immutable chairperson;
    Proposal[] public proposals;
    address payable public constant BURN_ADDRESS = payable(0x000000000000000000000000000000000000dEaD);
    uint256 public constant requiredBurn = 0.01 ether;
    uint256 public votingDeadlineBlock;

    event VoteCast(address indexed voter, uint256 indexed choiceIndex);
    event ExtendedDeadline(uint256 newDeadlineBlock);

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

    function vote(uint256 proposal) external payable onlyDuringVoting nonReentrant {
        require(msg.value == requiredBurn, "Incorrect Ether amount sent for registration");
        require(proposal < proposals.length, "Invalid proposal");
        proposals[proposal].voteCount += 1;
        emit VoteCast(msg.sender, proposal);
        (bool success, ) = BURN_ADDRESS.call{value: msg.value}("");
        require(success, "Ether transfer to burn address failed");
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

    function solveTie() external onlyAfterVoting { // maybe onlyChairperson
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