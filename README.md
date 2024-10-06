# Decentralized voting system
<p>Consider the Decentralized Voting System Smart Contract code in file <code>contracts/votingOriginal.sol</code></p>

## Issues and improvements
<p><i>Identify the bug(s) or vulnerability(ies) in the code, explain its impact and propose the
right solution.</i></p>

### Answer

#### Voting is not restricted in time 
<p>The balloting could go on forever. It is necessary to limit it somehow, otherwise it is not possible
to set an immutable winner. One alternative could be to let the chairperson close the voting. 
This increases centralization as it gives more power to the chairperson.
Another way would be to add time restrictions, either with block timestamp or with block height.
The timestamp approach provides a more precise estimation of when the voting concludes,
but it allows miners to game it at certain degree. On the other hand, the block approach 
is not precise in the exact time but it minimizes manipulation risks.</p>

#### Poor handling of ties
<p>The winningProposal function returns one value, and in case of tie, it returns the last occurrence
in the proposals array. This is misleading and unfair.
To address this problem, it is necessary to add logic to detect a tie and prevent to declare a winner
until it is resolved.</p>

#### Redundant <code>Voter.voteIndex</code>
<p>This property is initialized at 0, which is misleading since the user did not vote for the 0-index proposal.
In the context of this contract, this property is confusing since it does not have a clear purpose.
The proposed change is to delete it.</p>

#### No proposal requirements
<p>Duplicated proposals should not be allowed. 
It should not be possible to submit an empty array or only one proposal.
The code needs new logic to prevent this.<p>

#### Function access modifiers
<p>All functions are declared as <code>public</code>, but the contract security can be boosted
by tighthening access modifiers:</p>
<ul>
<li>winningProposal: <code>private</code></li>
<li>winnerName: <code>external</code></li>
<li>vote: <code>external</code></li>
<li>register: <code>external</code></li>
</ul>

#### Gas Optimization
<p>Strings should be carefully used in smart contracts because they account for a large portion of the gas 
consumption, specially stored in structures such as arrays. Gas costs can be optimized by 
replacing the <code>String</code> type with <code>bytes32</code> type, which can store a hashed string.</p>
<p>Also, trivial initializations can be spared (uint index = 0) to save some gas.</p>
<p>Changing function access modifiers as discussed in the previous point will also cut gas costs.</p>

#### No emission of events
<p>The original contract does not emit events, so off-chain applications are unable to monitor 
the voting process. At least two events should be logged: registering a voter and casting a vote. 
We could also consider emitting an event in <code>winningProposal</code> or <code>winnerName</code>, 
but two issues arise. First, the function could no longer be <code>view</code>, so it could not be 
called gas-free locally. Second, an event would be emitted unnecessarily every time 
the function is called.</p>

#### Centralization concerns
<p>This point is not exactly an issue but more a design choice. However, it is worth discussing due to 
its importance. In its current form, the chairperson concentrates both the ability to set the proposals 
and to register voters. This means the integrity of the voting is in hands of the chairperson's good will.</p>
<p>The contract is vulnerable to sybil attacks from the chairperson. They can register proxy identities and 
shift the leading proposal at any time. This defeats the purpose of a truly decentralized voting mechanism.</p>
<p>There are a few options to address this. One of them is to use decentralized identity solutions 
(oracles) to verify the voter's identity. However, this would increase the complexity of the contract. 
The other option is to establish a disincentive against sybil attacks by requiring the burning of a certain 
amount of ether for each vote. In this case, voting power would correlate with the user economic capacity, 
which might not be desirable either. 
</p>

#### Alternative implementations
<p>To further illustrate the points discussed, two alternative implementations are provided. The first  
maintains registration under the chairperson's control (<code>VotingImproved.sol</code>). The second 
implements the burn-to-vote scheme without prior registration (<code>VotingImprovedBurning.sol</code>).</p>

## Test cases
<p>Identify the functionalities under testing and give a brief description of what will be
verified. Identify also <b>edge cases.</b></p>

### Answer
<p>Only the functionalities present in the original contract provided will be considered in this section.</p>
<p>Only the functionalities present in the original contract provided will be considered in this section.</p>

#### Functionality: Initial deployment
<ul>
<li>TC1. <b>Deploy the contract with a specific identity</b>. It should establish that identity as the chairperson.</li>
<li>TC2. <b>Deploy the contract with two different proposals</b>. It should make two proposals available for voting.</li>
<li>TC3. <b>Deploy the contract with three different proposals</b>. It should make three proposals available for voting.</li>
<li>TC4. <b>Deploy the contract with two identical proposals</b>. It should not allow to deploy the contract.</li>
<li>TC5. <b>Deploy the contract with one proposal</b>. It should not allow to deploy the contract.</li>
<li>TC6. <b>Deploy the contract with an empty list of proposals</b>. It should not allow to deploy the contract.</li>
</ul>

#### Functionality: voter registration
<ul>
<li>TC7. <b>Register a new voter as the chairperson</b>. It should register the voter.</li>
<li>TC8. <b>Register two new voters as the chairperson</b>. It should register the two voters.</li>
<li>TC9. <b>Register an already registered voter as the chairperson</b>. It should not allow to register the voter.</li>
<li>TC10. <b>Register a voter as other than the chairperson</b>. It should not allow to register the voter.</li>
</ul>

#### Functionality: voting
<ul>
<li>TC11. <b>Vote a valid proposal as a registered voter who did not vote yet</b>. 
It should process the vote (proposal's count increases, voter flagged as voted, event emitted).</li>
<li>TC12. <b>Vote an invalid proposal</b>. It should not allow to vote.</li>
<li>TC13. <b>Vote as a non-registered voter</b>. It should not allow to vote.</li>
<li>TC14. <b>Vote as a voter who cast a vote already</b>. It should not allow to vote.</li>
</ul>

#### Functionality: getting results
<ul>
<li>TC15. <b>Check the winner as any user</b>. It should return the title of the most voted proposal.</li>
<li>TC16. <b>Check the winner multiple times</b>. It should return the correct winner consistently.</li>
<li>TC17. <b>Check the winner in case of a tie</b>. It should not return any winner.</li>
<li>TC18. <b>Check the winner and submit a valid vote</b>. It should not allow to vote (because there is a winner already).</li>
</ul>

#### Gas consumption
<ul>
<li>TC19. <b>Check gas consumption of the different functionalities with a large list of proposals</b>. 
It should show an acceptable profile of gas consumption.</li>
</ul>

## Web3 Automation framework
<p><i>If you had to choose a framework to write the test cases identified previously, which one would you choose and why?</i></p>

