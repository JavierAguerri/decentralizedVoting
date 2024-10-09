import { expect } from "chai";
import { Signer } from "ethers";

import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployFixture } from './fixture.ts';

async function registerVoters(votingContract, voters: Signer[]) {
  for (let voter of voters) {
    const voterAddress = await voter.getAddress();
    await votingContract.register(voterAddress);
  }
} 

async function voteProposal(votingContract, voter: Signer, proposalIndex: number) {
  await votingContract.connect(voter).vote(proposalIndex);
} 

describe("Getting results", function () {

  it("TC15. Given any user, When it checks the winner, It should return the title of the most voted proposal", async function () {
    const { votingContract, voter1, voter2, voter3, proposalList } = await loadFixture(deployFixture);
    await registerVoters(votingContract, [voter1, voter2, voter3]);
    const votedProposalIndex = 0;
    await voteProposal(votingContract, voter1, votedProposalIndex);
    await voteProposal(votingContract, voter2, votedProposalIndex);
    await voteProposal(votingContract, voter3, 1);
    expect(await votingContract.connect(voter3).winnerName())
    .equal(proposalList[votedProposalIndex]);
  });

  it("TC15b. Given any user, When it checks the winner, It should NOT return the title of a non-winning proposal", async function () {
    const { votingContract, voter1, voter2, voter3, proposalList } = await loadFixture(deployFixture);
    await registerVoters(votingContract, [voter1, voter2, voter3]);
    const votedProposalIndex = 0;
    await voteProposal(votingContract, voter1, votedProposalIndex);
    await voteProposal(votingContract, voter2, votedProposalIndex);
    await voteProposal(votingContract, voter3, 1);
    expect(await votingContract.connect(voter3).winnerName())
    .not.equal(proposalList[1]);
  });

  it("TC17. Given any user and there is a tie, When it checks the winner, It should not return any winner", async function () {
    const { votingContract, voter1, voter2, voter3 } = await loadFixture(deployFixture);
    await registerVoters(votingContract, [voter1, voter2]);
    await voteProposal(votingContract, voter1, 0);
    await voteProposal(votingContract, voter2, 1);
    await expect(votingContract.connect(voter3).winnerName()).to.be.revertedWith("Tied result");
  });

});