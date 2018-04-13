const HumanStandardToken = artifacts.require("./HumanStandardToken.sol");

module.exports = function(deployer) {
	deployer.deploy(HumanStandardToken, 1000000, 'DAY Token', 18, 'DAY');
};
