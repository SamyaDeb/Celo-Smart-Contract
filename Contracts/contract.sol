// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
