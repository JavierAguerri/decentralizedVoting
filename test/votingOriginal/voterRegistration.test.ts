import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployFixture } from './fixture.ts';

describe("Voter registration", function () {

  it("TC7. Given the owner is the chairperson, When it registers a new voter, It should register the voter", async function () {
    const { votingContract, voter1 } = await loadFixture(deployFixture);
    const voter1Address = await voter1.getAddress();
    await votingContract.register(voter1Address);
    expect((await votingContract.voters(voter1Address)).registered).to.be.true;
  });

  it("TC7b. Given the owner is the chairperson, When it registers a new voter, It should NOT register another voter", async function () {
    const { votingContract, voter1, voter2 } = await loadFixture(deployFixture);
    const voter1Address = await voter1.getAddress();
    const voter2Address = await voter2.getAddress();
    await votingContract.register(voter2Address);
    expect((await votingContract.voters(voter1Address)).registered).to.be.false;
  });

  it("TC10. Given the owner is NOT the chairperson, When it registers a voter, It should not allow to register the voter", async function () {
    const { votingContract, voter1, voter2 } = await loadFixture(deployFixture);
    const voter1Address = await voter1.getAddress();
    await expect(votingContract.connect(voter2).register(voter1Address)).to.be.revertedWith("Only chairperson can call this function");
  });

});