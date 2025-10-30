# 🗳️ Solidity Voting Dapp


A simple, secure, and educational smart contract for a permissioned voting system. This project is perfect for beginners learning the fundamentals of Solidity, including `structs`, `mappings`, `modifiers`, and admin controls.

## 📜 Project Description

This project provides the backend smart contract for a decentralized voting application (dapp). It is a **permissioned** system, meaning a central administrator (the "chairperson") has the authority to decide who is allowed to vote.

Once deployed, the chairperson can register voters, and those voters can then cast their one and only vote for a pre-defined proposal. The vote tally is transparent, secure, and automatically updated.

## 🤔 What It Does

Here is the step-by-step flow of the contract:

1.  **🚀 Deploy:** The contract is deployed to the blockchain with an initial list of proposal names (e.g., "Proposal A", "Proposal B"). The person who deploys the contract automatically becomes the `chairperson`.
2.  **✍️ Register:** The `chairperson` calls the `giveRightToVote` function to grant voting rights to specific wallet addresses.
3.  **🗳️ Vote:** Any address that has been given the right to vote can call the `vote` function *once* to cast their ballot.
4.  **📊 Tally:** Anyone on the blockchain can (for free) call the `getWinnerName` function to see the proposal that is currently in the lead or has won the election.

## ✨ Features

* **Admin Role:** Uses a `onlyChairperson` modifier to restrict sensitive functions (like `giveRightToVote`) to the contract deployer.
* **Voter Struct:** Uses a `Voter` struct to efficiently store information about each voter, including their voting `weight`, whether they have `voted`, and who they `delegate`d to.
* **Proposal Struct:** Uses a `Proposal` struct to store the `name` and `voteCount` for each proposal.
* **One-Voter-One-Vote:** Securely prevents double-voting by checking a `bool voted` flag for each voter.
* **Event-Driven:** Emits `VoterRegistered` and `Voted` events. A frontend application can easily listen for these events to update the UI in real-time.
* **Instant Winner:** Includes a `winningProposal()` view function that automatically loops through the proposals to find the one with the highest vote count.
* **Delegation-Ready:** The `Voter` struct is pre-built with a `delegate` field, making it easy to extend the contract to support vote delegation (a more advanced feature).

## 🔗 Deployed Smart Contract Link

https://celo-sepolia.blockscout.com/address/0xcf20D9e218539fd66035f226cBA9E2E41e1dcd33

## 📄 The Smart Contract

Here is the complete `Voting.sol` contract.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Voting
 * @dev A simple smart contract for a permissioned voting system.
 * The chairperson (deployer) can give voting rights to addresses.
 * Registered voters can vote for one of several proposals.
 */
contract Voting {

    // The address of the person who deployed the contract.
    address public chairperson;

    // A struct to store information about a single voter.
    struct Voter {
        uint weight;      // The voting power (default is 1).
        bool voted;       // True if the voter has already voted.
        address delegate; // The address this voter has delegated their vote to.
        uint vote;        // The index of the proposal they voted for.
    }

    // A struct to store information about a single proposal.
    struct Proposal {
        bytes32 name;     // A short name for the proposal (e.g., "Proposal A").
        uint voteCount;   // The total number of votes this proposal has received.
    }

    // A mapping to look up a Voter struct by their address.
    // 'public' creates a getter function to inspect voters.
    mapping(address => Voter) public voters;

    // A dynamic array to store all proposals.
    // 'public' creates a getter function for proposals.
    Proposal[] public proposals;

    // --- Events ---
    // Events are broadcast to the network and logged.
    // A frontend application can listen for these events.

    /**
     * @dev Emitted when a new voter is given the right to vote.
     * @param voterAddress The address of the voter.
     * @param weight The voting weight assigned to the voter.
     */
    event VoterRegistered(address indexed voterAddress, uint weight);

    /**
     * @dev Emitted when a vote is cast.
     * @param voterAddress The address of the voter.
     * @param proposalIndex The index of the proposal voted for.
     */
    event Voted(address indexed voterAddress, uint proposalIndex);

    /**
     * @dev Sets the deployer of the contract as the chairperson.
     * It also initializes the 'proposals' array with the provided names.
     *
     * Example: When deploying, you might pass ["Proposal 1", "Proposal 2"]
     */
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1; // Give chairperson voting rights by default

        // Create a Proposal struct for each name provided
        // and add it to the 'proposals' array.
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // --- Modifiers ---
    // Modifiers are reusable checks that can be added to functions.

    /**
     * @dev A modifier to restrict a function's access to only the chairperson.
     */
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this.");
        _; // This underscore runs the function's original code.
    }

    /**
     * @dev A modifier to check if the caller has the right to vote.
     */
    modifier canVote(address voterAddress) {
        Voter storage sender = voters[voterAddress];
        require(sender.weight > 0, "You have no right to vote.");
        require(!sender.voted, "You have already voted.");
        _;
    }

    // --- Functions ---

    /**
     * @notice Give a specific address the right to vote.
     * @dev Can only be called by the chairperson.
     * @param voter The address to register.
     */
    function giveRightToVote(address voter) external onlyChairperson {
        require(voters[voter].weight == 0, "Voter already registered.");
        voters[voter].weight = 1; // Set voting weight to 1
        emit VoterRegistered(voter, 1);
    }

    /**
     * @notice Cast a vote for a specific proposal.
     * @dev The voter must be registered and must not have voted yet.
     * @param proposalIndex The index of the proposal in the 'proposals' array.
     */
    function vote(uint proposalIndex) external canVote(msg.sender) {
        Voter storage sender = voters[msg.sender];

        sender.voted = true;
        sender.vote = proposalIndex;
        proposals[proposalIndex].voteCount += sender.weight;

        emit Voted(msg.sender, proposalIndex);
    }

    /**
     * @notice Finds the winning proposal.
     * @dev Iterates through all proposals to find the one with the highest vote count.
     * @return winningProposalIndex The index of the winning proposal.
     */
    function winningProposal() public view returns (uint winningProposalIndex) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposalIndex = p;
            }
        }
    }

    /**
     * @notice Gets the name of the winning proposal.
     * @return winnerName The bytes32 name of the winning proposal.
     */
    function getWinnerName() public view returns (bytes32 winnerName) {
        winnerName = proposals[winningProposal()].name;
    }
}