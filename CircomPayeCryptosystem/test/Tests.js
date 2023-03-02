const { expect } = require('chai')
const { ethers } = require('hardhat')
const registrationProof = require('./RegistrationProof/proof.json')
const registrationPublic = require('./RegistrationProof/public.json')
const registrationInput = require('./RegistrationProof/input.json')
const transferProof = require('./TransferProof/proof.json')

describe('zkToken', function () {
  let zkToken, registrationVerifier, transferVerifier, client1, client2, client3

  const fee = ethers.utils.parseUnits('0.001', 'ether')

  before(async function () {
    ;[client1, client2, client3] = await ethers.getSigners()

    const RegistrationVerifier = await hre.ethers.getContractFactory(
      'RegistrationVerifier',
    )
    registrationVerifier = await RegistrationVerifier.deploy()
    await registrationVerifier.deployed()

    const TransferVerifier = await hre.ethers.getContractFactory(
      'TransferVerifier',
    )
    transferVerifier = await TransferVerifier.deploy()
    await transferVerifier.deployed()

    const zkToken_ = await hre.ethers.getContractFactory('zkToken')
    zkToken = await zkToken_.deploy(
      transferVerifier.address,
      registrationVerifier.address,
    )
    await zkToken.deployed()
  })

  it('name', async function () {
    expect(await zkToken.name()).to.eq('zkToken')
  })

  it('symbol', async function () {
    expect(await zkToken.symbol()).to.eq('ZKT')
  })

  it('verifyRegistrationProof', async function () {
    await registrationVerifier.verifyProof(
      [registrationProof.pi_a[0], registrationProof.pi_a[1]],
      [
        [registrationProof.pi_b[0][1], registrationProof.pi_b[0][0]],
        [registrationProof.pi_b[1][1], registrationProof.pi_b[1][0]],
      ],
      [registrationProof.pi_c[0], registrationProof.pi_c[1]],
      registrationPublic,
    )
  })
  it('registration', async function () {
    await zkToken.registration(
      [
        registrationInput.encryptedBalance,
        [registrationInput.pubKey[0], registrationInput.pubKey[2]],
      ],
      [registrationProof.pi_a[0], registrationProof.pi_a[1]],
      [
        [registrationProof.pi_b[0][1], registrationProof.pi_b[0][0]],
        [registrationProof.pi_b[1][1], registrationProof.pi_b[1][0]],
      ],
      [registrationProof.pi_c[0], registrationProof.pi_c[1]],
      registrationPublic,
    )

    expect(await zkToken.balanceOf(client1.address)).to.eq(
      registrationInput.encryptedBalance,
    )
  })
})
