// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract TransferVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            8642237710098054647842634451864045334142070025834703931930753317928533025466,
            17569705359901002778222531910342085753577692333773948427478679177588872959416
        );

        vk.beta2 = Pairing.G2Point(
            [
                9542812728198829894836756115896384327634820649911255296596040464154116552918,
                19251642390432294709435488514487093644638719961475829905006592770680852593942
            ],
            [
                7844257090084086699746367362512987319859636681733202871524290484855931360370,
                15876846814095663931074116966093185282998261306851374748446275091891174611799
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                8571588268032412345366036724843757061922796998687545018206873081399466021626,
                6069658560852024687683289340880553530102892350972320713622436169823939997959
            ],
            [
                19883207328624859926059982211694936476305824234324847389257675975773585043913,
                7152589745698265421617506941713044616384335111493336523465408992569354593353
            ]
        );
        vk.IC = new Pairing.G1Point[](3);

        vk.IC[0] = Pairing.G1Point(
            13674826797251604752115295628492598387179261198520968163643669089020576190337,
            19526000736789680406657498115185597893466193721882009003073406459893730390408
        );

        vk.IC[1] = Pairing.G1Point(
            3658771442302419089567156318996931604723425654471229459903047877762926561833,
            7030017285820708154614791911150620240605944797393405929852751932469987382128
        );

        vk.IC[2] = Pairing.G1Point(
            16552167471744798986732407604004586985101176137118249885106858406548700574902,
            6774636838942272737743428436177766642691177101357200778635683264728568813540
        );
    }

    function verify(
        uint[] memory input,
        Proof memory proof
    ) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(
                input[i] < snark_scalar_field,
                "verifier-gte-snark-scalar-field"
            );
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.IC[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint /*2*/[] memory input
    ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
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
