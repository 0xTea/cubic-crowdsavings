const CrowdSaving = artifacts.require("CrowdSaving");
// const Users = artifacts.require("Users");

module.exports = function(deployer) {
  deployer.deploy(CrowdSaving);
  // deployer.deploy(Users);
};
