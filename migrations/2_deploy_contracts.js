const SimpleStorage = artifacts.require("CrowdSaving");
const TutorialToken = artifacts.require("Users");

module.exports = function(deployer) {
  deployer.deploy(CrowdSaving);
  deployer.deploy(Users);
};
