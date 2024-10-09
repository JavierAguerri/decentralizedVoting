import { ethers } from "hardhat";
import { Signer } from "ethers";


export const contractName = "VotingImproved";
export const proposal1 = ethers.encodeBytes32String("Proposal1");
export const proposal2 = ethers.encodeBytes32String("Proposal2");
export const proposal3 = ethers.encodeBytes32String("Proposal3");
export const blockDuration = 10000;

export async function deployFixture() {
  let chairperson: Signer;
  let voter1: Signer;
  let voter2: Signer;
  let voter3: Signer;

  const proposalList = [proposal1, proposal2];
  [chairperson, voter1, voter2, voter3] = await ethers.getSigners();
  const votingContract = await ethers.deployContract(contractName,[proposalList, blockDuration],chairperson);
  return { votingContract, chairperson, voter1, voter2, voter3, proposalList };
}