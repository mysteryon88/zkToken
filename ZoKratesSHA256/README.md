# zkToken

To get started, follow these steps:

### 1. Install ZoKrates (Docker or Linux)

### 2. Compile .zok files
```
zokrates compile -i *.zok
```
### 3. Perform the setup phase
```
zokrates setup
```
### 4. Execute the program and generate a proof of computation
```
./getProof.sh
```
### 5. Export a solidity verifier
```
zokrates export-verifier
```
### 6. Replace receiverVerifier.sol and senderVerifier.sol
