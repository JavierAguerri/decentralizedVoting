import { ethers } from "hardhat";
import { Signer } from "ethers";

export const contractName = "VotingOriginal";

export async function deployFixture() {
    let chairperson: Signer;
    let voter1: Signer;
    let voter2: Signer;
    let voter3: Signer;
    const proposalList = ["Proposal1", "Proposal2"];

    [chairperson, voter1, voter2, voter3] = await ethers.getSigners();
    const votingContract = await ethers.deployContract(contractName,[proposalList],chairperson);

    return { votingContract, chairperson, voter1, voter2, voter3, proposalList };
 }
