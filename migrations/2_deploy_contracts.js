const fs = require('fs')

const DAYToken = artifacts.require("./HumanStandardToken.sol");
const DAYFaucet = artifacts.require("./DAYFaucet.sol");

module.exports = function(deployer) {
	const totalTokenSupply = 1000000*1e18;

	deployer.deploy(DAYToken, totalTokenSupply, 'DAY Token', 18, 'DAY')
	.then(() => {
    	return deployer.deploy(DAYFaucet, DAYToken.address, 333*1e18, 60);
	})
	.then(() => {
        return DAYToken.at(DAYToken.address).transfer(DAYFaucet.address, totalTokenSupply)
    })
	.then(() => {
		const addresses = {
			DAYToken: DAYToken.address,
			DAYFaucet: DAYFaucet.address,
		};

		const abis = {
			DAYToken: DAYToken.abi,
			DAYFaucet: DAYFaucet.abi,
		};

		fs.writeFileSync('DAY_addresses.json', JSON.stringify(addresses));
		fs.writeFileSync('DAY_abis.json', JSON.stringify(abis));
    });
};
