const { expect } = require('chai')
const { ethers } = require('hardhat')

const registrationProofA = require('./RegistrationProof/proofA.json')
const registrationPublicA = require('./RegistrationProof/publicA.json')
const registrationInputA = require('./RegistrationProof/inputA.json')

const registrationProofB = require('./RegistrationProof/proofB.json')
const registrationPublicB = require('./RegistrationProof/publicB.json')
const registrationInputB = require('./RegistrationProof/inputB.json')

const mintProof = require('./MintProof/proof.json')
const mintPublic = require('./MintProof/public.json')
// const mintInput = require('./MintProof/input.json')

const transferProofA = require('./TransferProof/proofA.json')
const transferPublicA = require('./TransferProof/publicA.json')
const transferInputA = require('./TransferProof/inputA.json')

describe('zkToken', function () {
  let zkToken,
    registrationVerifier,
    transferVerifier,
    mintVerifier,
    clientA,
    clientB

  const fee = ethers.utils.parseUnits('0.001', 'ether')

  before(async function () {
    ;[clientA, clientB] = await ethers.getSigners()

    const RegistrationVerifier = await hre.ethers.getContractFactory(
      'RegistrationVerifier'
    )
    registrationVerifier = await RegistrationVerifier.deploy()
    await registrationVerifier.deployed()

    const TransferVerifier = await hre.ethers.getContractFactory(
      'TransferVerifier'
    )
    transferVerifier = await TransferVerifier.deploy()
    await transferVerifier.deployed()

    const MintVerifier = await hre.ethers.getContractFactory('MintVerifier')
    mintVerifier = await MintVerifier.deploy()
    await mintVerifier.deployed()

    const ZKToken = await hre.ethers.getContractFactory('zkToken')
    zkToken = await ZKToken.deploy(
      transferVerifier.address,
      registrationVerifier.address,
      mintVerifier.address
    )
    await zkToken.deployed()
  })
  /*    
          decryption
  
  function powToMod(base, power, module) {
    if (power === 1n) return base
    if (power % 2n === 0n)
      return powToMod(base, power / 2n, module) ** 2n % module
    return (powToMod(base, power - 1n, module) * base) % module
  }

  // powToMod(366142356n, 1447804911n, 219020071n)

  function L(u, n) {
    return (u - 1n) / n
  }

  function decryption(c, n, l, mu) {
    return (L(powToMod(c, l, n * n), n) * mu) % n
  }
*/
  it('name', async function () {
    expect(await zkToken.name()).to.eq('zkToken')
  })

  it('symbol', async function () {
    expect(await zkToken.symbol()).to.eq('ZKT')
  })

  it('verifyRegistrationProof', async function () {
    await registrationVerifier.verifyProof(
      [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
      [
        [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
        [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
      ],
      [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
      registrationPublicA
    )
  })

  it('verifyMintProof', async function () {
    await mintVerifier.verifyProof(
      [mintProof.pi_a[0], mintProof.pi_a[1]],
      [
        [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
        [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
      ],
      [mintProof.pi_c[0], mintProof.pi_c[1]],
      mintPublic
    )
  })

  it('verifyTransferProof', async function () {
    await transferVerifier.verifyProof(
      [transferProofA.pi_a[0], transferProofA.pi_a[1]],
      [
        [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
        [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
      ],
      [transferProofA.pi_c[0], transferProofA.pi_c[1]],
      transferPublicA
    )
  })

  it('registration A', async function () {
    await zkToken.connect(clientA).registration(
      [
        registrationInputA.encryptedBalance,
        [registrationInputA.pubKey[0], registrationInputA.pubKey[2]],
      ],
      [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
      [
        [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
        [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
      ],
      [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
      registrationPublicA
    )

    expect(await zkToken.balanceOf(clientA.address)).to.eq(
      registrationInputA.encryptedBalance
    )
  })

  it('registration B', async function () {
    await zkToken.connect(clientB).registration(
      [
        registrationInputB.encryptedBalance,
        [registrationInputB.pubKey[0], registrationInputB.pubKey[2]],
      ],
      [registrationProofB.pi_a[0], registrationProofB.pi_a[1]],
      [
        [registrationProofB.pi_b[0][1], registrationProofB.pi_b[0][0]],
        [registrationProofB.pi_b[1][1], registrationProofB.pi_b[1][0]],
      ],
      [registrationProofB.pi_c[0], registrationProofB.pi_c[1]],
      registrationPublicB
    )

    expect(await zkToken.balanceOf(clientB.address)).to.eq(
      registrationInputB.encryptedBalance
    )
  })

  it('mint A', async function () {
    await zkToken.mint(
      clientA.address,
      [mintProof.pi_a[0], mintProof.pi_a[1]],
      [
        [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
        [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
      ],
      [mintProof.pi_c[0], mintProof.pi_c[1]],
      mintPublic
    )

    console.log(await zkToken.balanceOf(clientA.address))
    /*
    expect(
      decryption(
        await zkToken.balanceOf(clientA.address),
        46783589n,
        11692464n,
        39229921n
      )
    ).to.eq(mintInput.value)
    */
  })

  it('Transfer A to B', async function () {})
})
