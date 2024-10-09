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
but it allow miners to game it to a certain degree. On the other hand, the block approach 
is not precise in the exact time but it minimizes manipulation risks.</p>

#### Poor handling of a tie vote
<p>The winningProposal function returns one value, and in case of tie, it returns the last occurrence
in the proposals array. This is misleading and unfair.
To address this problem, it is necessary to add logic to detect a tie and prevent to declare a winner
until it is resolved.</p>

#### Redundant <code>Voter.voteIndex</code>
<p>This property is initialized at 0, which is misleading since the user did not vote for the 0-index proposal.
In the context of this contract, this property is confusing since it does not have a clear purpose.
The proposed change is to delete it.</p>

#### No proposal requirements
<p>Duplicate proposals should not be allowed. 
It should not be possible to submit an empty array or only one proposal.
The code needs new logic to prevent this.<p>

#### Solidity compiler version
<p>It is highly recommended to update the Solidity compiler version to its latest stable version whenever possible, 
since newer releases come with the latest security fixes and other improvements.</p>

#### Function access modifiers
<p>All functions are declared as <code>public</code>, but the contract security can be boosted
by tighthening access modifiers:</p>
<ul>
<li>winningProposal: <code>private</code></li>
<li>winnerName: <code>external</code></li>
<li>vote: <code>external</code></li>
<li>register: <code>external</code></li>
</ul>

#### Chairperson (contract owner) is not immutable
<p>Make this state variable immutable so it is safer and optimized.</p>

#### Gas Optimization
<p>Strings should be carefully used in smart contracts because they account for a large portion of the gas 
consumption, specially stored in structures such as arrays. Gas costs can be optimized by 
replacing the <code>String</code> type with <code>bytes32</code> type, which can store a hashed string.</p>
<p>Some other optimizations:</p>
<ul>
<li>Cache array lengths</li>
<li>Changing function access modifiers as discussed in the previous point will also cut gas costs.</li>
</ul>

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
and to register voters. This means the integrity of the voting is in the hands of the chairperson's good will.</p>
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
<li>TC1. When it deploys the contract with a specific identity, It should establish the contract deployer as the chairperson.</li>
<li>TC2. When it deploys the contract with two different proposals, It should make two proposals available for voting.</li>
<li>TC3. When it deploys the contract with three different proposals, It should make three proposals available for voting.</li>
<li>TC4. When it deploys the contract with two identical proposals, It should not allow to deploy a contract.</li>
<li>TC5. When it deploys the contract with one proposal, It should not allow to deploy the contract.</li>
<li>TC6. When it deploys the contract with an empty list of proposals, It should not allow to deploy the contract.</li>
</ul>

#### Functionality: voter registration
<ul>
<li>TC7. Given the owner is the chairperson, When it registers a new voter, It should register the voter.</li>
<li>TC8. Given the owner is the chairperson, When it registers two new voters, It should register the two voters.</li>
<li>TC9. Given the owner is the chairperson, When it registers an already registered voter, It should not allow to register the voter.</li>
<li>TC10. Given the owner is NOT the chairperson, When it registers a voter, It should not allow to register the voter.</li>
</ul>

#### Functionality: voting
<ul>
<li>TC11. Given the user is a registered voter and it did not vote yet, When it votes a valid proposal, 
It should process the vote (proposal's count increases, voter flagged as voted, event emitted).</li>
<li>TC12. Given the user is a registered voter, When it votes an invalid proposal, It should not allow to vote.</li>
<li>TC13. Given the user is NOT a registered voter, When it votes, It should not allow to vote.</li>
<li>TC14. Given the user is a registered voter and it voted already, When it votes, It should not allow to vote.</li>
</ul>

#### Functionality: getting results
<ul>
<li>TC15. Given any user, When it checks the winner, It should return the title of the most voted proposal.</li>
<li>TC16. Given any user, When it checks the winner multiple times, It should return the correct winner consistently.</li>
<li>TC17. Given any user and there is a tie, When it checks the winner, It should not return any winner.</li>
<li>TC18. Given any user, When it checks the winner and submits a valid vote, It should not allow to vote (because there is a winner already).</li>
</ul>

#### Gas consumption
<ul>
<li>Check gas consumption of the different functionalities with a large list of proposals.</li>
</ul>

## Web3 Automation framework
<p><i>If you had to choose a framework to write the test cases identified previously, which one would you choose and why?</i></p>

### Answer
<p>Let's discuss and compare some of the suitable frameworks for this task.</p>

#### Truffle
<p>It is the most battle-tested framework. It is javascript-based and has plenty of features and customization possibilities.
Although truffle is established and has a large community of users and developers, Consensys, the software company that developed 
and maintaned Truffle and Ganache (local blockchain tool), announced on September 21st, 2023 the sunset of these tools.
In case I had to set up a new project I would not choose a deprecated tool, so I would rule out truffle.</p>

#### Foundry
<p>As a Rust-based framework, Foundry achieves a great performance when it comes to compiling and running tests. It allows 
to write tests directly in Solidity and it features built-in fuzz testing, which generates random data for testing. 
However, as an emerging alternative, its ecosystem is yet to grow as large as its competitors.</p>

#### Brownie
<p>This would be a good choice if Python was the language required for scripting the tests. It has a rich set of features and 
its console provides a simple way to perform on-the-fly testing and debugging in a local RPC environment, 
or interact with contracts in a remote chain. </p>
<p>An interesting difference is that Python runs synchronously, whereas Javascript is asynchronous. Since the EVM (or RVM) is single threaded, there is no need for asynchronous calls when running tests and deployment scripts. Therefore Python would be more convenient because we avoid all the <code>async</code> clutter.</p>
<p>Solidity uses integers, which are natively supported by Python unlinke Javascript.</p>

#### The choice: Hardhat
<p>It would be the chosen framework. Here is why:</p>
<ul>
<li>It has an extensive ecosystem of highly customizable plugins which enhances its testing capabilities.</li>
<li>It has a large and vibrant community behind, plus comprehensive documentation.</li>
<li>It comes with a built-in local Ethereum network designed specifically for development and testing.</li>
<li>It stands out at debugging and logging, facilitating test case development.</li>
<li>It supports Typescript, which easies some of the Javascript shortcomings.</li>
</ul>

## Test case implementation
<p>Select one of the functionalities identified in the 1.2 exercise and write the test cases
in the framework chosen in the 1.3 exercise. You can deliver a GitHub repository link or a zip file containing:</p>
<ul>
<li>The smart contract code.</li>
<li>The suite of the test cases.</li>
<li>A README file explaining the testing approach, how to run the tests, and any findings or observations.</li>
</ul>

### Answer
<p>The functionality selected to implement the test cases is the contract initialization and deployment. However,
some test cases of other functionalities have been also implemented to further illustrate the approach. Two suites
have been implemented, one for the original contract as provided, and one for the improved proposal.</p>

#### Execute the tests
<p>In order to run the tests, follow these instructions:</p>
<ul>
<li>Download project</li>
<li>Install latest nvm</li>
<li>Use nvm to install node 20.17 and npm 10.8.2</li>
<li>Navigate to the project folder</li>
<li>In the terminal, run <code>npm install</code></li>
<li>To run the tests, you can choose which version of the contract you want to test:<br>
<code>npx hardhat test # all tests, for both contract implementations</code><br>
<code>npx hardhat test test/votingOriginal/*.test.ts # original contract provided in the exercise</code><br>
<code>npx hardhat test test/votingImproved/*.test.ts # proposed implementation with improvements</code><br>
</li>
</ul>

#### Testing approach

<p>The testing approach in this demo is grounded on unit testing (solitary and social unit testing) to verify the contract's 
functionalities. Deployment and initialization tests are solitary unit tests as they test the constructor in isolation,
while collections covering contract features are mostly based on social unit testing since they verify outcomes of interactions 
between methods.</p>

<p>Tests are organized and segregated by feature to enhance readability, maintainability, and scalability of the suite. 
This organized structure is further supported by the use of fixtures as pre-defined steps, which promote DRY principles
and help de-cluttering scripts, making them more concise and focused on specific assertions.</p>

<p>As of techniques, negative testing is used, which involves validating that the smart contracts handle invalid or unexpected 
inputs gracefully (e.g. initialization with too few or no proposals). This is important for ensuring that the contracts 
revert appropriately under erroneous conditions. Additionally, boundary value testing assesses the contract's behavior at 
the extreme ends of input ranges (e.g. initialization with the minimum number of proposals, vote ends in a tie). 
In this way, the integrity of the contract under edge conditions can be verified.</p>

<p>Security has been considered in this strategy, particularly focusing on users other than the admin. This ensures that 
only authorized users can perform privileged operations, preventing potential exploits. This is illustrated in TC10 and TC13.</p>

<p>The test suit leverages Hardhat's built-in parallel testing capabilities, optimizing test execution time. 
This is particularly beneficial as the testing project scales and includes a large numer of test cases.</p>

<p>Gherkin syntax (BDD) has been incorporated to add clarity and expressiveness to test cases. 
Structuring tests into Given-When-Then formats helps articulate the context, actions, and expected outcomes clearly. 
It facilitates better collaboration between technical and non-technical stakeholders.</p>

<p>The tests results highlight some of the issues discussed in section 1, in particular TC4, TC5, TC6 (proposal requirements) 
and TC17 (tie vote handling). In case of the original contract, test cases covering the registration process do not assert 
event emission for clarity reasons, but in a real testing project they would, so they would fail as well.</p>

#### Additional considerations

<p>Beyond executing the test suite, additional steps are customary in the process of smart contract development:</p>
<ul>
<li>Comment and document the project.</li>
<li>Analyze code coverage (e.g. Solidity-Coverage).</li>
<li>Analyze test coverage (e.g. solcover).</li>
<li>Use of static analysis tools such as Slither or Mythril.</li>
<li>Perform a thorough manual review of the smart contract code in search of vulnerabilities and issues.</li>
<li>Use of dynamic analysis tools such as Echidna or Manticore.</li>
<li>For critical smart contracts, do a formal verification.</li>
<li>Review gas consumption, and apply relevant gas optimization techniques.</li>
<li>Request an external audit.</li>
</ul>

<p>The implemented solution can be further improved. Here are some ideas:</p>
<ul>
<li>Use common test automation tools: BDD tools (e.g. Cucumber), reporting (e.g. Allure).</li>
<li>Consider fuzz-testing (Hardhat has it built-in).</li>
<li>Consider mutation testing (e.g. SuMo).</li>
</ul>

<p>A final thought. <b>MANUAL REVIEW IN SMART CONTRACTS IS CRUCIAL. Do not solely rely on automated tools for smart contract verification. 
According to a recent <a href="https://arxiv.org/pdf/2304.02981">IEEE research</a>, current security tools can only detect 
8-20% of exploitable bugs. This highlights a notable deficiency in automated bug-finding capabilities. Particularly 
challenging are issues such as asset lock, logical errors, or oracle manipulations, which prove to be extremely difficult 
for security analyzers alone to detect.</b></p>


