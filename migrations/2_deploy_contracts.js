const fs = require('fs')

const DAYToken = artifacts.require("./HumanStandardToken.sol");
const DAYFaucet = artifacts.require("./DAYFaucet.sol");

module.exports = function(deployer) {
	deployer.deploy(DAYToken, 1000000, 'DAY Token', 18, 'DAY')
	.then(() => {
    	return deployer.deploy(DAYFaucet, DAYToken.address, 333, 60);
	})
	.then(() => {
		const contracts = {
			DAYToken: DAYToken.address,
			DAYFaucet: DAYFaucet.address,
		};

		fs.writeFileSync('DAY_contracts.json', JSON.stringify(contracts));
    });
};
