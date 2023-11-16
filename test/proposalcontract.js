const ProposalContract = artifacts.require("ProposalContract");

contract("ProposalContract", accounts => {
let proposalContract;
const owner = accounts[0];
const user1 = accounts[1];
beforeEach(async () => {
  proposalContract = await ProposalContract.new();
});
describe("create Proposal", () => {
  it("create proposal", async () => {
  await proposalContract.create("votingApp", "Vote for candidate",5, { from: owner });
    const proposal = await proposalContract.getCurrentProposal();
    assert.equal(proposal.title, "votingApp", "Problem with title name");
    assert.equal(proposal.description, "Vote for candidate", "Problem with description");
  });
});


describe("create Proposal and Vote", () => {
  it("vote ", async () => {
    await proposalContract.create("votingApp", "Vote for candidate",5, { from: owner });
    await proposalContract.vote(0, { from: user1 });
      const proposal = await proposalContract.getCurrentProposal();
      assert.equal(proposal.pass,1, "Problem with voting ");
      assert.equal(proposal.current_state, false, "Problem with current state");
      assert.equal(proposal.is_active, true, "Problem with is active");
    });

});


describe("create Proposal,Vote,terminate", () => {
    it("terminate ", async () => {
      await proposalContract.create("votingApp", "Vote for candidate",5, { from: owner });
      await proposalContract.vote(0, { from: user1 });    
      await proposalContract.teminateProposal( { from: owner });
        const proposal = await proposalContract.getCurrentProposal();
        assert.equal(proposal.is_active, false, "Problem with is active");
      });
});

});