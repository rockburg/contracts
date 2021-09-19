require('dotenv').config()
require('solidity-coverage')
require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-etherscan')

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
	solidity: '0.8.4',
	networks: {
		hardhat: {
			initialBaseFeePerGas: 0, // workaround from https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136 . Remove when that issue is closed.
		},
		mumbai: {
			url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_ID}`,
			accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
		},
		polygon: {
			url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_ID}`,
			accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
		},
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
}
