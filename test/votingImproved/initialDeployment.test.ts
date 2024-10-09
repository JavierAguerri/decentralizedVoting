import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { contractName, proposal1, proposal2, proposal3, blockDuration, deployFixture } from './fixture.ts';

describe("Initial deployment", function () {

  it("TC1. When it deploys the contract with a specific identity, It should establish the contract deployer as the chairperson", async function () {
    const { votingContract, chairperson } = await loadFixture(deployFixture);
    expect(await votingContract.chairperson())
      .equal(await chairperson.getAddress());
  });

  it("TC2. When it deploys the contract with two different proposals, It should make two proposals available for voting", async function () {
    const { votingContract, chairperson, proposalList } = await loadFixture(deployFixture);
    const initialLength = BigInt(await ethers.provider.getStorage(await votingContract.getAddress(), 0));
    expect(initialLength).equal(proposalList.length);
  });

  it("TC3. When it deploys the contract with three different proposals, It should make three proposals available for voting", async function () {
    const [chairperson] = await ethers.getSigners();
    const proposalList = [proposal1, proposal2, proposal3];
    const votingContract = await ethers.deployContract(contractName, [proposalList, blockDuration], chairperson);
    const initialLength = BigInt(await ethers.provider.getStorage(await votingContract.getAddress(), 0));
    expect(initialLength).equal(proposalList.length);
  });

  it("TC4. When it deploys the contract with two identical proposals, It should not allow to deploy a contract", async function () {
    const [chairperson] = await ethers.getSigners();
    const proposalList = [proposal1, proposal1];
    await expect(ethers.deployContract(contractName, [proposalList, blockDuration], chairperson))
      .to.be.revertedWith("Proposals cannot be duplicated");
  });

  it("TC5. When it deploys the contract with one proposal, It should not allow to deploy the contract", async function () {
    const [chairperson] = await ethers.getSigners();
    const proposalList = [proposal1];
    await expect(ethers.deployContract(contractName, [proposalList, blockDuration], chairperson))
      .to.be.revertedWith("At least 2 proposals needed");
  });

  it("TC6. When it deploys the contract with an empty list of proposals, It should not allow to deploy the contract", async function () {
    const [chairperson] = await ethers.getSigners();
    const proposalList: String[] = [];
    await expect(ethers.deployContract(contractName, [proposalList, blockDuration], chairperson))
      .to.be.revertedWith("At least 2 proposals needed");
  });

});