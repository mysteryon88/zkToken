# zkToken

## Final repositories

[Contracts](https://github.com/druzhtech/zkToken-contracts) |
[Web interface](https://github.com/druzhtech/zkToken-front)

## CircomPayeCryptosystemV1

The first version of the token protocol with hidden balances.

Uses homomorphic encryption (Paye cryptosystem) of balances, sums up balances inside a smart contract.

Tools: circom (Linux) + snarkJS

## CircomPayeCryptosystemV2

The second version of the protocol

Uses homomorphic balance encryption (Paye cryptosystem), the recipient's new balance is calculated on the sender's side. Proof of computation is sent to the smart contract.

Tools: circom (Linux) + snarkJS

## CircomPayeCryptosystemV3

The third version of the protocol

Gas optimization.

Uses homomorphic balance encryption (Paye cryptosystem), the balances of the recipient and sender are homomorphically added and subtracted in the smart contract with the transfer amount calculated on the sender's side. The proof of computation is sent to the smart contract.

`npm run inputs`: generate input data to compute the witness

`npm run proofs`: generate proofs

`npm run siberiumTest`: testing in Siberium testnet

Tools: circom (Linux) + snarkJS + using paillier-bigint

## ZoKratesSHA256

The very first version of the protocol. Uses two proofs for token transfer: sender proof and receiver proof. Used to hide balances SHA256

Tools: ZoKrates (Linux or Docker)
