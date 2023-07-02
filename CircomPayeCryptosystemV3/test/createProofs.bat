:: cd test
:: create registration proof A
node registrationProof/generate_witness.js registrationProof/registration.wasm inputs/regInputA.json registrationProof/witnessA.wtns
snarkjs groth16 prove registrationProof/registration_0001.zkey registrationProof/witnessA.wtns registrationProof/proofA.json registrationProof/publicA.json
snarkjs groth16 verify registrationProof/verification_key.json registrationProof/publicA.json registrationProof/proofA.json
:: create registration proof B
node registrationProof/generate_witness.js registrationProof/registration.wasm inputs/regInputB.json registrationProof/witnessB.wtns
snarkjs groth16 prove registrationProof/registration_0001.zkey registrationProof/witnessB.wtns registrationProof/proofB.json registrationProof/publicB.json
snarkjs groth16 verify registrationProof/verification_key.json registrationProof/publicB.json registrationProof/proofB.json
:: create mint proof A
node mintProof/generate_witness.js mintProof/mint.wasm inputs/mintInputA.json mintProof/witness.wtns
snarkjs groth16 prove mintProof/mint_0001.zkey mintProof/witness.wtns mintProof/proof.json mintProof/public.json
snarkjs groth16 verify mintProof/verification_key.json mintProof/public.json mintProof/proof.json