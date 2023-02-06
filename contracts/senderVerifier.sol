// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract senderVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(
            uint256(
                0x045df34501b43f14739e5fbcada25cdf410cffad75cbc1f625f7caea25d40489
            ),
            uint256(
                0x177300c804b7725aa0ab958150feeda15c0e4606189d47ea5cbeafb45730bcc5
            )
        );
        vk.beta = Pairing.G2Point(
            [
                uint256(
                    0x0b483a89ae511a2afd33cd08ac73f05c3b01d89bd757327feb577433f2365e2b
                ),
                uint256(
                    0x2fb861924e8d767ac85168f2e673a133340a44484e82b83b0b3a4c8dac55883b
                )
            ],
            [
                uint256(
                    0x290b1f892aceda77f9eb8f1e10b0c9fc24805bbc759546ad44ef39b070c04054
                ),
                uint256(
                    0x055b235b3292b1111a0b00388a2690386101d12b56ac1d7a1861e8ff5f9000f1
                )
            ]
        );
        vk.gamma = Pairing.G2Point(
            [
                uint256(
                    0x1b8c42e475207b6dbf0c8f5fb6fa4d165285eaf7dc39efd926623ad8cdbcdbc7
                ),
                uint256(
                    0x07b8dfaae26b2ebaac55fccd903ce2472f8130a8f77f24799c407c24f8142f42
                )
            ],
            [
                uint256(
                    0x15065fa6a70160981ebae418b5b620cd18215d2e57f8a8d9fe8a08c4ae74ab46
                ),
                uint256(
                    0x0bdcf2f90815cdca2fce4625fd92095a70a0c313c802a6701c6749461b39cbb9
                )
            ]
        );
        vk.delta = Pairing.G2Point(
            [
                uint256(
                    0x0d7912a8e3a6c3a9ad4ac1d3adf45f0e38bcc6b14bd6cf53535a0c99a70e76c8
                ),
                uint256(
                    0x2b258f1a0b87308d0f1bf8623e3854be9cfe3ac12168bde94fba0c5b7043c637
                )
            ],
            [
                uint256(
                    0x03e42b6bb4701e9b2cfc074823765a6f41e568b4f29bf451b714d82f85cfc2ac
                ),
                uint256(
                    0x21dfb98d6e84a2c896aae975d35e40158038498f17102ef9ac8b30c85850c42a
                )
            ]
        );
        vk.gamma_abc = new Pairing.G1Point[](7);
        vk.gamma_abc[0] = Pairing.G1Point(
            uint256(
                0x04719b034e5d3a776818cb25c73065c271fd534ade95ac4ed18444bda4683000
            ),
            uint256(
                0x10a26dc289461ea35132683abaf219f37d3485dec7d5bfd02b8ad10503bf269b
            )
        );
        vk.gamma_abc[1] = Pairing.G1Point(
            uint256(
                0x14189cd55ca2471af77163455638b21bb60005518c70798f3e1975db7c32afbe
            ),
            uint256(
                0x172d8d6be8d09f2aec38cf68ee82c68b5bc48c35fa9e4d84def24f0ca3e3aa5d
            )
        );
        vk.gamma_abc[2] = Pairing.G1Point(
            uint256(
                0x0c2a951d3c13fe5195459b6d71a9f391516da418a9dca79b5a4ceb3b9eb8bc6b
            ),
            uint256(
                0x15bd130e3a7766df783620f320e6f1318e1fd4934e158f8fed360bd39702aa54
            )
        );
        vk.gamma_abc[3] = Pairing.G1Point(
            uint256(
                0x05f0fd775df78555d915d723edeee5f1a7109f82f3784d0b9a0bd86df5d6917d
            ),
            uint256(
                0x0bf7a5c22253bb35fac4c88e93c8286b8aa75435c5e668a4b369f0aba0c49057
            )
        );
        vk.gamma_abc[4] = Pairing.G1Point(
            uint256(
                0x0ef32bc13382653ea7f3dd0d308c5f13d8bcb6a35850e8f78f52b78753ab222b
            ),
            uint256(
                0x24bd2e271dbf70b746d2c4c82319e57a63b68993d22cc3436886b88b9015b679
            )
        );
        vk.gamma_abc[5] = Pairing.G1Point(
            uint256(
                0x140fe464bb34a514c7e6bb8c69036a9faf2786270e8c679da27c5a640d4143c2
            ),
            uint256(
                0x16ee4f23a856f05ff6d3eed33a3d3abf9148bef28e251664bc592e708fe24baa
            )
        );
        vk.gamma_abc[6] = Pairing.G1Point(
            uint256(
                0x2cf1a2089c4fb5eea713ccb53d1a72a63b8c2ad4b30757e687ba2f42744236a9
            ),
            uint256(
                0x095626dc87b66dbdb5a96b9d919b5697b32aeb67cc6f057c68c3aa801b4741b2
            )
        );
    }

    function verify(
        uint[] memory input,
        Proof memory proof
    ) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if (
            !Pairing.pairingProd4(
                proof.a,
                proof.b,
                Pairing.negate(vk_x),
                vk.gamma,
                Pairing.negate(proof.c),
                vk.delta,
                Pairing.negate(vk.alpha),
                vk.beta
            )
        ) return 1;
        return 0;
    }

    function verifyTx(
        Proof memory proof,
        uint[6] memory input
    ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](6);

        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
