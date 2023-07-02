const paillierBigint = require('paillier-bigint')
const fs = require('fs')

let publicKeyA, privateKeyA, publicKeyB, privateKeyB

async function initializeKeys() {
  const keysA = await paillierBigint.generateRandomKeys(32)
  publicKeyA = keysA.publicKey
  privateKeyA = keysA.privateKey

  const keysB = await paillierBigint.generateRandomKeys(32)
  publicKeyB = keysB.publicKey
  privateKeyB = keysB.privateKey

  const keysAjson = {
    n: publicKeyA.n.toString(),
    g: publicKeyA.g.toString(),
    mu: privateKeyA.mu.toString(),
    lambda: privateKeyA.lambda.toString(),
  }

  const keysBjson = {
    n: publicKeyB.n.toString(),
    g: publicKeyB.g.toString(),
    mu: privateKeyB.mu.toString(),
    lambda: privateKeyB.lambda.toString(),
  }

  const keysAjsonString = JSON.stringify(keysAjson)
  fs.writeFile('test/inputs/keysA.json', keysAjsonString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing file:', err)
    } else {
    }
  })

  const keysBjsonString = JSON.stringify(keysBjson)
  fs.writeFile('test/inputs/keysB.json', keysBjsonString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing file:', err)
    } else {
    }
  })
}

async function regInputA() {
  const zero = 0n
  const r = BigInt(Math.floor(Math.random() * Number(publicKeyA.n)))

  const inputAJSON = {
    encryptedBalance: publicKeyA.encrypt(zero, r).toString(),
    balance: '0',
    pubKey: [publicKeyA.g.toString(), r.toString(), publicKeyA.n.toString()],
  }

  const jsonString = JSON.stringify(inputAJSON)
  fs.writeFile('test/inputs/regInputA.json', jsonString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing file:', err)
    } else {
    }
  })
}

async function regInputB() {
  const zero = 0n
  const r = BigInt(Math.floor(Math.random() * Number(publicKeyB.n)))

  const inputAJSON = {
    encryptedBalance: publicKeyB.encrypt(zero, r).toString(),
    balance: '0',
    pubKey: [publicKeyB.g.toString(), r.toString(), publicKeyB.n.toString()],
  }

  const jsonString = JSON.stringify(inputAJSON)
  fs.writeFile('test/inputs/regInputB.json', jsonString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing file:', err)
    } else {
    }
  })
}

async function minInputA() {
  const value = 10
  const r = BigInt(Math.floor(Math.random() * Number(publicKeyA.n)))

  const inputAJSON = {
    encryptedValue: publicKeyA.encrypt(value, r).toString(),
    value: value.toString(),
    receiverPubKey: [
      publicKeyA.g.toString(),
      r.toString(),
      publicKeyA.n.toString(),
    ],
  }

  const jsonString = JSON.stringify(inputAJSON)
  fs.writeFile('test/inputs/mintInputA.json', jsonString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing file:', err)
    } else {
    }
  })
}

initializeKeys().then(() => {
  regInputA()
  regInputB()
  minInputA()
})
