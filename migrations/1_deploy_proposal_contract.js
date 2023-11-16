const fs=require("fs");
const ProposalContract = artifacts.require("ProposalContract");
module.exports = async function (deployer) {
  await deployer.deploy(ProposalContract);
  const instance = await ProposalContract.deployed();
  let proposalContractAddress = await instance.address;
  let config = "export const proposalContractAddress = " + proposalContractAddress;
  console.log("proposalContractAddress = " + proposalContractAddress);
  let data = JSON.stringify(config);
  fs.writeFileSync("config.js", JSON.parse(data));
  };