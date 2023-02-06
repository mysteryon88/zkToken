// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract receiverVerifier {
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
                0x0b214326f6197fcf99f12b4f36fe67c5e493a93612807207c57b9e79175af7b8
            ),
            uint256(
                0x0506882ff32dd3a69ecbb4600f87b7b58f5876474b1b6627d922340025c89415
            )
        );
        vk.beta = Pairing.G2Point(
            [
                uint256(
                    0x219efa77274fd3db77be896badeed09c8070db541eed58bc6c6e7c971928e744
                ),
                uint256(
                    0x071a23ae1d0481821f07711337948fadd24f17cd6e29a1ce860ba788248dba61
                )
            ],
            [
                uint256(
                    0x029bf1268cb2ee14cc1b18a92985f2178c9f93270eb1cbcc9e4af1920b93bdcd
                ),
                uint256(
                    0x0c8a726818a05f14b691512cdbb557c4b3fd7c48c21b8f741b6c15960c35457c
                )
            ]
        );
        vk.gamma = Pairing.G2Point(
            [
                uint256(
                    0x2b829c1df4bd3a2bc3e5f114d1e4971f5f0ad9b6f1bd18a19594ccc8293786c6
                ),
                uint256(
                    0x19573d25ffc15349822cb42109d07f2e7e72781f06d6f04f51dd0647e2662173
                )
            ],
            [
                uint256(
                    0x1acfc94370438644c30028573f8fa41fd109ef1e8dc006a288e450aac9400b29
                ),
                uint256(
                    0x29c76b1466438f85bab517543373f4ef71c94a6016a901104e95aaa6b8d0accb
                )
            ]
        );
        vk.delta = Pairing.G2Point(
            [
                uint256(
                    0x200ce7c0c0554d68dadce3d01eca7240130d2e3d040482613650f3308c7e5202
                ),
                uint256(
                    0x12be685c4a52df3135af821d73ecc8be94305b35997d6a57757cf08c6795f276
                )
            ],
            [
                uint256(
                    0x05f7c2dc59fd56b43233e46eeb1c8f1204700451abeb8cb213204440775a0172
                ),
                uint256(
                    0x2e2ddcb098b28e1aeec2573317b1c5bfa0a89a2da1e37a3890b9b80ad4189a68
                )
            ]
        );
        vk.gamma_abc = new Pairing.G1Point[](7);
        vk.gamma_abc[0] = Pairing.G1Point(
            uint256(
                0x11314de0e85f76465b438cb92fbe4f15e2a9372592d7ec363cd5342767745cd6
            ),
            uint256(
                0x0f1be488d2052170ddbcb714712f6491be305fc8eed28341be911abd47700cb0
            )
        );
        vk.gamma_abc[1] = Pairing.G1Point(
            uint256(
                0x14e7592d3e05ad60ce1a9e353bf02ac0c61ffebc20b8f443f938aebec9851a48
            ),
            uint256(
                0x014e2d90bb2b4f7c6bbe0a7cd555115d4992ee9d04e9866eb9b27d5eb83522b0
            )
        );
        vk.gamma_abc[2] = Pairing.G1Point(
            uint256(
                0x0e64e567cda8e13dbe05c61e7174960ec6056001ad6d70aa1d79b2f3aa8ec38c
            ),
            uint256(
                0x2af36dbe5290dd1d022090b961a85803b13ac4eb32c1ba0c161f2d8d59bbd1c0
            )
        );
        vk.gamma_abc[3] = Pairing.G1Point(
            uint256(
                0x0b114f55a314743bdbb51b7055955aec05520e58c6844a311de68ba0268668ce
            ),
            uint256(
                0x082155e6c1fc811f53397e781e81dcd7196e340c295d01c22d3c3838340ed3df
            )
        );
        vk.gamma_abc[4] = Pairing.G1Point(
            uint256(
                0x26cd16493c1fa649fd5eb114dec17f59aaade6cf61b0cebcea27a701e6313314
            ),
            uint256(
                0x0f3d10c26464a5099e6e2737697aacfbbbc211c341405e7a7b08a04253ee85a4
            )
        );
        vk.gamma_abc[5] = Pairing.G1Point(
            uint256(
                0x017289e55f97eeb7f75d0b78ac4b292d6901a5d7af5772c2d59cfb9b9e9abb4a
            ),
            uint256(
                0x2a718aa76b38962bf84656c34f27800aedf14671c4551de4d088fccded0117a3
            )
        );
        vk.gamma_abc[6] = Pairing.G1Point(
            uint256(
                0x2d95e75a163140b4a11eb86d948f009d5d7db6dfdf08b88b9ed3ab8b336a7ec0
            ),
            uint256(
                0x0ea2bc9e608c8ac5f017d0ef0a958e708068743a94ed13be86892f55a3792d26
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
