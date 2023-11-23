// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "../contracts/ProposalContract.sol";
import "remix_accounts.sol";

contract ProposalContract_test {
ProposalContract proposalContract;
address testAccount1;

function beforeEach() public {
proposalContract = new ProposalContract(); 
testAccount1 = TestsAccounts.getAccount(1);
}

/// #sender: account-0
// Test creating a proposal
function testCreateProposal() public { 
proposalContract.create("Test Proposal","vote for candidate", 5);
ProposalContract.Proposal memory proposal = proposalContract.getCurrentProposal(); 
Assert.equal(proposal.description, "vote for candidate", "Proposal description should match"); 
Assert.equal(proposal.total_vote_to_end, 5, "Total votes to end should match");
}

// Test terminate proposal
function testTerminateProposal() public {
proposalContract.create("Test Proposal","vote for candidate", 5);
proposalContract.teminateProposal();
ProposalContract. Proposal memory proposal = proposalContract.getCurrentProposal(); 
Assert.equal(proposal.is_active, false, "Proposal should be terminated");
}
// Test getProposal function
function testGetProposal() public {
proposalContract.create("Test Proposal1","vote for candidate1", 5);
proposalContract.create("Test Proposal2","vote for candidate2", 5);
ProposalContract.Proposal memory firstProposal = proposalContract.getProposal(1); 
ProposalContract.Proposal memory secondProposal = proposalContract.getProposal(2);
Assert.equal(firstProposal.description, "vote for candidate1", "First proposal should be retrievable"); 
Assert.equal(secondProposal.description, "vote for candidate2", "Second proposal should be retrievable");
}

/// #sender: account-0
function testIsVotedOwner() public {
// Create a proposal and vote on it
proposalContract.create("Test Proposal1","vote for candidate1", 5);
// Check that the voter's address is marked as voted
Assert.equal(proposalContract.isVoted (address (this)), true, "Address should be marked as voted");
}

/// #sender: account-1
function testIsVotedNonOwner() public {
// Check that the non owner's address is marked as voted
Assert.equal(proposalContract.isVoted(testAccount1), false, "Address shouldn't be marked as voted");
}

/// #sender: account-0
function testChangeOwner() public {
// Change the owner of the contract to a new address
address newOwner = address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); 
proposalContract.setOwner(newOwner);
address currentOwner=newOwner;
Assert.equal(currentOwner, newOwner, "Owner should be updated to the new address");
}

function testVote() public {
// Create a new proposel
proposalContract.create("Test Proposal1","vote for candidate1", 5);
// Retrieve the current proposal and check that the vote count is recorded correctly 
ProposalContract.Proposal memory proposal = proposalContract.getCurrentProposal(); 
Assert.equal(proposal.approve, 0, "One vote for approval should be recorded by a non-owner");
}

}
