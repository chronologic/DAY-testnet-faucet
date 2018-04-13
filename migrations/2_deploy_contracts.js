const HumanStandardToken = artifacts.require("./HumanStandardToken.sol");
const DAYFaucet = artifacts.require("./DAYFaucet.sol");

module.exports = function(deployer) {
	deployer.deploy(HumanStandardToken,1000000, 'DAY Token', 18, 'DAY').then(function() {
    	return deployer.deploy(DAYFaucet, HumanStandardToken.address, 333, 60);
	});
};
