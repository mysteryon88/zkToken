const { expect } = require('chai')
const { ethers } = require('hardhat')
const paillierBigint = require('paillier-bigint')

const keysA = require('./inputs/keysA.json')
const keysB = require('./inputs/keysB.json')

const registrationInputA = require('./inputs/regInputA.json')
const registrationPublicA = require('./registrationProof/publicA.json')
const registrationProofA = require('./registrationProof/proofA.json')

const registrationInputB = require('./inputs/regInputB.json')
const registrationPublicB = require('./registrationProof/publicB.json')
const registrationProofB = require('./registrationProof/proofB.json')

const mintInput = require('./inputs/mintInputA.json')
const mintPublic = require('./MintProof/public.json')
const mintProof = require('./MintProof/proof.json')

/*
const transferProofA = require('./TransferProof/proofA.json')
const transferPublicA = require('./TransferProof/publicA.json')
const transferInputA = require('./TransferProof/inputA.json')

const transferProofB = require('./TransferProof/proofB.json')
const transferPublicB = require('./TransferProof/publicB.json')
const transferInputB = require('./TransferProof/inputB.json')
*/
describe('zkToken', function () {
  let zkToken,
    registrationVerifier,
    transferVerifier,
    mintVerifier,
    clientA,
    clientB,
    clientC,
    publicKeyA,
    privateKeyA,
    publicKeyB,
    privateKeyB

  const fee = ethers.utils.parseUnits('0.001', 'ether')

  publicKeyA = new paillierBigint.PublicKey(BigInt(keysA.n), BigInt(keysA.g))
  privateKeyA = new paillierBigint.PrivateKey(
    BigInt(keysA.lambda),
    BigInt(keysA.mu),
    publicKeyA
  )
  publicKeyB = new paillierBigint.PublicKey(BigInt(keysB.n), BigInt(keysB.g))
  privateKeyB = new paillierBigint.PrivateKey(
    BigInt(keysB.lambda),
    BigInt(keysB.mu),
    publicKeyB
  )

  before(async function () {
    ;[clientA, clientB, clientC] = await ethers.getSigners()

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
  /*
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
*/
  it('registration A', async function () {
    const tx = await zkToken.connect(clientA).registration(
      [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
      [
        [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
        [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
      ],
      [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
      registrationPublicA
    )

    const receipt = await tx.wait()

    console.log(
      'Gas used by registration: ',
      '\x1b[33m',
      receipt.gasUsed.toString(),
      '\x1b[0m'
    )

    const balance = await zkToken.balanceOf(clientA.address)

    console.log(
      'Client A balance after registration',
      balance,
      privateKeyA.decrypt(BigInt(balance))
    )

    expect(balance).to.eq(registrationInputA.encryptedBalance)

    expect(BigInt(0)).to.eq(privateKeyA.decrypt(BigInt(balance)))
  })

  it('registration B', async function () {
    const tx = await zkToken.connect(clientB).registration(
      [registrationProofB.pi_a[0], registrationProofB.pi_a[1]],
      [
        [registrationProofB.pi_b[0][1], registrationProofB.pi_b[0][0]],
        [registrationProofB.pi_b[1][1], registrationProofB.pi_b[1][0]],
      ],
      [registrationProofB.pi_c[0], registrationProofB.pi_c[1]],
      registrationPublicB
    )

    const receipt = await tx.wait()

    console.log(
      'Gas used by registration: ',
      '\x1b[33m',
      receipt.gasUsed.toString(),
      '\x1b[0m'
    )

    const balance = await zkToken.balanceOf(clientB.address)

    console.log(
      'Client B balance after registration',
      balance,
      privateKeyB.decrypt(BigInt(balance))
    )

    expect(balance).to.eq(registrationInputB.encryptedBalance)

    expect(BigInt(0)).to.eq(privateKeyB.decrypt(BigInt(balance)))
  })

  it('mint A', async function () {
    const tx = await zkToken.mint(
      clientA.address,
      [mintProof.pi_a[0], mintProof.pi_a[1]],
      [
        [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
        [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
      ],
      [mintProof.pi_c[0], mintProof.pi_c[1]],
      mintPublic
    )

    const receipt = await tx.wait()

    console.log(
      'Gas used by mint: ',
      '\x1b[33m',
      receipt.gasUsed.toString(),
      '\x1b[0m'
    )

    const balance = await zkToken.balanceOf(clientA.address)

    console.log(
      'Client A balance after registration',
      balance,
      privateKeyA.decrypt(BigInt(balance))
    )

    expect(BigInt(10)).to.eq(privateKeyA.decrypt(BigInt(balance)))
  })
  /*
  it('Revert self-transfer', async function () {
    await expect(
      zkToken.connect(clientB).transfer(
        clientB.address,
        [transferProofA.pi_a[0], transferProofA.pi_a[1]],
        [
          [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
          [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
        ],
        [transferProofA.pi_c[0], transferProofA.pi_c[1]],
        transferPublicA
      )
    ).to.be.revertedWith('you cannot send tokens to yourself')
  })

  it('Transfer A to B', async function () {
    const tx = await zkToken.connect(clientA).transfer(
      clientB.address,
      [transferProofA.pi_a[0], transferProofA.pi_a[1]],
      [
        [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
        [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
      ],
      [transferProofA.pi_c[0], transferProofA.pi_c[1]],
      transferPublicA
    )

    const receipt = await tx.wait()

    console.log(
      'Gas used by transfer: ',
      '\x1b[33m',
      receipt.gasUsed.toString(),
      '\x1b[0m'
    )

    expect(await zkToken.balanceOf(clientA.address)).to.eq(
      transferInputA.newEncryptedBalance
    )

    expect(
      decryption(
        await zkToken.balanceOf(clientB.address),
        17942993n,
        8967090n,
        15889415n
      )
    ).to.eq(transferInputA.value)

    console.log(
      'Client A balance after transfer A to B',
      await zkToken.balanceOf(clientA.address)
    )

    console.log(
      'Client B balance after transfer A to B',
      await zkToken.balanceOf(clientB.address)
    )
  })

  it('Transfer B to A', async function () {
    const tx = await zkToken.connect(clientB).transfer(
      clientA.address,
      [transferProofB.pi_a[0], transferProofB.pi_a[1]],
      [
        [transferProofB.pi_b[0][1], transferProofB.pi_b[0][0]],
        [transferProofB.pi_b[1][1], transferProofB.pi_b[1][0]],
      ],
      [transferProofB.pi_c[0], transferProofB.pi_c[1]],
      transferPublicB
    )

    const receipt = await tx.wait()

    console.log(
      'Gas used by transfer: ',
      '\x1b[33m',
      receipt.gasUsed.toString(),
      '\x1b[0m'
    )

    expect(await zkToken.balanceOf(clientB.address)).to.eq(
      transferInputB.newEncryptedBalance
    )

    expect(
      decryption(
        await zkToken.balanceOf(clientA.address),
        46783589n,
        11692464n,
        39229921n
      )
    ).to.eq(BigInt(transferInputB.value) + 5n) // 5 - old balance

    console.log(
      'Client A balance after transfer B to A',
      await zkToken.balanceOf(clientA.address)
    )

    console.log(
      'Client B balance after transfer B to A',
      await zkToken.balanceOf(clientB.address)
    )
  })

  it('revert error registration', async function () {
    await expect(
      zkToken.connect(clientA).registration(
        [transferProofA.pi_a[0], transferProofA.pi_a[1]],
        [
          [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
          [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
        ],
        [transferProofA.pi_c[0], transferProofA.pi_c[1]],
        registrationPublicA
      )
    ).to.be.revertedWith('you are registered')
  })
  */
  it('onlyRegistered modifier', async function () {
    await expect(
      zkToken.connect(clientB).transfer(
        clientC.address,
        [mintProof.pi_a[0], mintProof.pi_a[1]],
        [
          [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
          [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
        ],
        [mintProof.pi_c[0], mintProof.pi_c[1]],
        mintPublic
      )
    ).to.be.revertedWith('user not registered')
  })
})
