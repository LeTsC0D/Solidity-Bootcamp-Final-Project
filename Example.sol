// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingContract {
    address public owner;
    
    enum VoteOption { None, Approve, Reject, Pass }
    
    struct Proposal {
        string description;
        string title;
        uint256 total_vote_to_end;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        bool is_active;
        bool current_state;
    }
    
    // Proposal[] public proposal_history;
    mapping(uint256 => Proposal) proposal_history; 
    uint256[] public proposalIndices;

    event ProposalCreated(uint256 proposalId, string description, uint256 total_vote_to_end);
    event Voted(uint256 proposalId, address voter, VoteOption vote);
    event is_active(uint256 proposalId, bool approved);
    event current_state(uint256 proposalId, bool approved);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    modifier validProposal(uint256 proposalId) {
        require(proposalId < proposalIndices.length, "Invalid proposal ID");
        require(proposal_history[proposalId].is_active, "Proposal is not active");
        _;
    }
    
    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot vote");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory _description, uint256 _total_vote_to_end) external onlyOwner {
        uint256 proposalId = proposalIndices.length;
        proposalIndices.push(proposalId);
        // uint256 proposalId = proposal_history.length;
        proposal_history[proposalId] = Proposal(
            _description,
            _total_vote_to_end,
            0,
            0,
            0,
            proposalEnded: true,
            state: ProposalState.Ongoing
        );
        // proposal_history.push(Proposal(_description,_total_vote_to_end,0,0,0,true,false));      
        emit ProposalCreated(proposalId, _description, _total_vote_to_end);
    }

    function vote(uint256 _proposalId, VoteOption _vote) external validProposal(_proposalId) notOwner {
        require(_vote == VoteOption.Approve || _vote == VoteOption.Reject || _vote == VoteOption.Pass, "Invalid vote option");
        
        Proposal storage proposal = proposal_history[_proposalId];
        require(proposal.approve + proposal.reject + proposal.pass + 1 <= proposal.total_vote_to_end, "Vote limit exceeded");
        // proposal.voters[msg.sender] = _vote;
        
        if (_vote == VoteOption.Approve) {
            proposal.approve++;
        } else if (_vote == VoteOption.Reject) {
            proposal.reject++;
        } else {
            proposal.pass++;
        }

        emit Voted(_proposalId, msg.sender, _vote);
        
        if (proposal.approve >= proposal.total_vote_to_end) {
            proposal.is_active = true;
            emit is_active(_proposalId, true);
        } else if (proposal.reject >= proposal.total_vote_to_end) {
            proposal.is_active = true;
            emit is_active(_proposalId, false);
        }
        if(proposal.approve+proposal.pass>proposal.reject){
            proposal.current_state=true;
            emit current_state(_proposalId, true);
        }else{
           proposal.current_state=false; 
           emit current_state(_proposalId, false);
        }
    }
    
    function getProposalCount() external view returns (uint256) {
        return proposal_history.length;
    }

    function getProposal(uint256 _proposalId) external view returns (string memory, uint256, uint256, uint256, uint256, bool,bool) {
        require(_proposalId < proposal_history.length, "Invalid proposal ID");
        
        Proposal storage proposal = proposal_history[_proposalId];
        return (
            proposal.description,
            proposal.total_vote_to_end,
            proposal.approve,
            proposal.reject,
            proposal.pass,
            proposal.is_active,
            proposal.current_state
        );
    }
}
