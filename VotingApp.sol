// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingContract {
    address public owner;
    
    enum VoteOption { None, Approve, Reject, Pass }
    
    struct Proposal {
        string description;
        uint256 voteLimit;
        uint256 approveVotes;
        uint256 rejectVotes;
        uint256 passVotes;
        bool proposalEnded;
        mapping(address => VoteOption) voters;
    }
    
    Proposal[] public proposals;
    
    event ProposalCreated(uint256 proposalId, string description, uint256 voteLimit);
    event Voted(uint256 proposalId, address voter, VoteOption vote);
    event ProposalEnded(uint256 proposalId, bool approved);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    modifier validProposal(uint256 proposalId) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(!proposals[proposalId].proposalEnded, "Proposal has already ended");
        require(proposals[proposalId].voters[msg.sender] == VoteOption.None, "You have already voted");
        _;
    }
    
    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot vote");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory _description, uint256 _voteLimit) external onlyOwner {
        uint256 proposalId = proposals.length;
        proposals.push();
        Proposal storage newProposal = proposals[proposalId];
        
        newProposal.description = _description;
        newProposal.voteLimit = _voteLimit;
        newProposal.approveVotes = 0;
        newProposal.rejectVotes = 0;
        newProposal.passVotes = 0;
        newProposal.proposalEnded = false;        
        emit ProposalCreated(proposalId, _description, _voteLimit);
    }

    function vote(uint256 _proposalId, VoteOption _vote) external validProposal(_proposalId) notOwner {
        require(_vote == VoteOption.Approve || _vote == VoteOption.Reject || _vote == VoteOption.Pass, "Invalid vote option");
        
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.approveVotes + proposal.rejectVotes + proposal.passVotes + 1 <= proposal.voteLimit, "Vote limit exceeded");
        proposal.voters[msg.sender] = _vote;
        
        if (_vote == VoteOption.Approve) {
            proposal.approveVotes++;
        } else if (_vote == VoteOption.Reject) {
            proposal.rejectVotes++;
        } else {
            proposal.passVotes++;
        }

        emit Voted(_proposalId, msg.sender, _vote);
        
        if (proposal.approveVotes >= proposal.voteLimit) {
            proposal.proposalEnded = true;
            emit ProposalEnded(_proposalId, true);
        } else if (proposal.rejectVotes >= proposal.voteLimit) {
            proposal.proposalEnded = true;
            emit ProposalEnded(_proposalId, false);
        }
    }
    
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    function getProposal(uint256 _proposalId) external view returns (string memory, uint256, uint256, uint256, uint256, bool) {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.voteLimit,
            proposal.approveVotes,
            proposal.rejectVotes,
            proposal.passVotes,
            proposal.proposalEnded
        );
    }
}
