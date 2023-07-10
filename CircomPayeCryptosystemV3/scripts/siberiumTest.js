const ethers = require('ethers')
require('dotenv').config()
const privateKey = process.env.PRIVATE_KEY

const adresses = require('./adresses.json')
const abiZKToken = require('../abi/contracts/zkToken.sol/zkToken.json')
const abiRegistrationVerifier = require('../abi/contracts/Verifiers/RegistrationVerifier.sol/RegistrationVerifier.json')
//const registrationInputA = require('../inputs/regInputA.json')
const registrationInputA = require('../test/inputs/regInputA.json')
const registrationPublicA = require('../test/registrationProof/publicA.json')
const registrationProofA = require('../test/registrationProof/proofA.json')

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    'https://rpc.test.siberium.net'
  )

  const network = await provider.getNetwork()
  console.log('Chain ID:', network.chainId)

  const blockNumber = await provider.getBlockNumber()
  console.log('Current block number:', blockNumber)

  const wallet = new ethers.Wallet(privateKey, provider)

  const balance = await provider.getBalance(wallet.address)
  console.log('Current balance:', ethers.utils.formatEther(balance))

  const zkToken = new ethers.Contract(adresses.ZKTOKEN, abiZKToken, wallet)
  const name = await zkToken.name()
  console.log('Name:', name)

  const RegistrationVerifier = new ethers.Contract(
    adresses.REGISTRATIONVERIFIER,
    abiRegistrationVerifier,
    wallet
  )

  const regVerifier = await RegistrationVerifier.verifyProof(
    [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
    [
      [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
      [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
    ],
    [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
    registrationPublicA
  )
  console.log('Test registration verifier:', regVerifier)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
