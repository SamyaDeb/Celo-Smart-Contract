# 🗳️ Solidity Voting Dapp

<img width="1470" height="956" alt="Screenshot 2025-10-30 at 11 20 48 AM" src="https://github.com/user-attachments/assets/13c21201-59f9-489b-a050-1e7153fddbab" />


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
