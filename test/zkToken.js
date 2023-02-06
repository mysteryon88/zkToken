const { expect } = require('chai')
const { ethers } = require('hardhat')
const senderProof = require('./senderProof.json')
const receiverProof = require('./receiverProof.json')
const receiverProofMint5 = require('./receiverProofMint 5.json')
const receiverProofMint10 = require('./receiverProofMint 10.json')
const senderProof2 = require('./senderProof2.json')
const receiverProof2 = require('./receiverProof2.json')

describe('zkToken', function () {
  let zkToken, client1, client2, client3
  before(async function () {
    ;[client1, client2, client3] = await ethers.getSigners()
    const ReceiverVerifier = await hre.ethers.getContractFactory(
      'receiverVerifier',
    )
    const receiverVerifier = await ReceiverVerifier.deploy()
    await receiverVerifier.deployed()

    console.log(`ReceiverVerifier deployed to ${receiverVerifier.address}`)

    const SenderVerifier = await hre.ethers.getContractFactory('senderVerifier')
    const senderVerifier = await SenderVerifier.deploy()
    await senderVerifier.deployed()

    console.log(`SenderVerifier deployed to ${senderVerifier.address}`)

    const zkToken_ = await hre.ethers.getContractFactory('zkToken')
    zkToken = await zkToken_.deploy(
      senderVerifier.address,
      receiverVerifier.address,
    )
    await zkToken.deployed()

    console.log(`SenderVerifier deployed to ${zkToken.address}`)
  })

  it('name', async function () {
    expect(await zkToken.name()).to.eq('zkToken')
  })

  it('symbol', async function () {
    expect(await zkToken.symbol()).to.eq('ZKT')
  })

  it('mint 5', async function () {
    await zkToken.mint(client2.address, receiverProofMint5.proof, [
      receiverProofMint5.inputs[0],
      receiverProofMint5.inputs[1],
      receiverProofMint5.inputs[4],
      receiverProofMint5.inputs[5],
    ])

    var balance = await zkToken.balanceOf(client2.address)
    // 0 + 5
    expect(balance[0] == '263561599766550617289250058199814760685').to.eq(true)
    expect(balance[1] == '65303172752238645975888084098459749904').to.eq(true)
  })

  it('mint revert', async function () {
    await expect(
      zkToken.mint(client2.address, receiverProofMint5.proof, [
        receiverProofMint5.inputs[0],
        receiverProofMint5.inputs[1],
        receiverProofMint5.inputs[4],
        receiverProofMint5.inputs[5],
      ]),
    ).to.be.revertedWith('False Proof')
  })

  it('mint 10', async function () {
    await zkToken.mint(client1.address, receiverProofMint10.proof, [
      receiverProofMint10.inputs[0],
      receiverProofMint10.inputs[1],
      receiverProofMint10.inputs[4],
      receiverProofMint10.inputs[5],
    ])

    var balance = await zkToken.balanceOf(client1.address)
    // 0 + 10
    expect(balance[0] == '261673453623746781313652579402536373323').to.eq(true)
    expect(balance[1] == '140016560968775928873505512069829327042').to.eq(true)
  })
  it('transfer 1', async function () {
    // client1 = 10
    // client2 = 5

    await zkToken.transfer(
      client2.address,
      receiverProof.proof,
      senderProof.proof,
      [
        senderProof.inputs[0],
        senderProof.inputs[1],
        senderProof.inputs[4],
        senderProof.inputs[5],
        receiverProof.inputs[4],
        receiverProof.inputs[5],
      ],
    )
    // client1 = 5
    // client2 = 10
    // 10
    var balance = await zkToken.balanceOf(client2.address)
    expect(balance[0] == '261673453623746781313652579402536373323').to.eq(true)
    expect(balance[1] == '140016560968775928873505512069829327042').to.eq(true)
    // 5
    balance = await zkToken.balanceOf(client1.address)
    expect(balance[0] == '263561599766550617289250058199814760685').to.eq(true)
    expect(balance[1] == '65303172752238645975888084098459749904').to.eq(true)
  })

  it('transfer 2', async function () {
    // client1 = 5
    // client3 = 0

    await zkToken.transfer(
      client3.address,
      receiverProof2.proof,
      senderProof2.proof,
      [
        senderProof2.inputs[0],
        senderProof2.inputs[1],
        senderProof2.inputs[4],
        senderProof2.inputs[5],
        receiverProof2.inputs[4],
        receiverProof2.inputs[5],
      ],
    )
    // client1 = 0
    // client3 = 5
    // 0
    var balance = await zkToken.balanceOf(client1.address)
    expect(balance[0] == '326522724692461750427768532537390503835').to.eq(true)
    expect(balance[1] == '89059515727727869117346995944635890507').to.eq(true)
    // 5
    balance = await zkToken.balanceOf(client3.address)
    expect(balance[0] == '263561599766550617289250058199814760685').to.eq(true)
    expect(balance[1] == '65303172752238645975888084098459749904').to.eq(true)
  })
})
