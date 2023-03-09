require('@nomicfoundation/hardhat-toolbox')
require('@nomiclabs/hardhat-ethers')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */

const privateKey = process.env.PRIVATE_KEY
const endpoint = process.env.URL

module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: endpoint,
      accounts: [`0x${privateKey}`],
    },
  },
}
