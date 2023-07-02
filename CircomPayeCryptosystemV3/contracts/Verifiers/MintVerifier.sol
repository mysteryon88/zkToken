// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract MintVerifier {
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
            2884759592400354745711897972849002617121384089168865907093026454403665394538,
            6614075615839083041311222545457458113525780766749358651244967471421006190630
        );

        vk.beta2 = Pairing.G2Point(
            [
                7546718058447718319406427431340078014469330500278932845345911118134242044871,
                1690442320622051588655007902867784427979913307082840700791270465434550937531
            ],
            [
                9760677910404933322416332323206611193398741383377947337619565227937930072074,
                8136761457326696722284016800591479077182033572434092707075432526865778710512
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
                10785365326728744010492119587619251046242002528394404785139662898353903621827,
                8229146235569906557837036294940814558719900607519254083472828611481895842925
            ],
            [
                344847794204906343123858735631146380206185310333285170192696162189965761356,
                14086127885755481204631508840331127604844699217040176588932630190259851311233
            ]
        );
        vk.IC = new Pairing.G1Point[](5);

        vk.IC[0] = Pairing.G1Point(
            20464936055253643289514121380331736031026151916348875628668266669527169679322,
            16136902016599214780317673697805139463421293438941233886865317448570100704565
        );

        vk.IC[1] = Pairing.G1Point(
            14315097442173559387438851162129240255841381261598947823393396062656725236479,
            10102215790017239537336322403428493396796580390164609560083546911479407594940
        );

        vk.IC[2] = Pairing.G1Point(
            3633763504633816441296687505086591269621301191561916185966424253873610544876,
            8817865242771612497317501645112339344646405962446962281714866747327457364793
        );

        vk.IC[3] = Pairing.G1Point(
            13900424260566327746559532875548680273768828584946437670264462252903754084124,
            7172682092767654496358400505477619893447526009745450931244846124011469916630
        );

        vk.IC[4] = Pairing.G1Point(
            8369055857475578410929638735737624602342048450682665906201048851806184002812,
            1171542897802675964800797637866542221566060760610876429276738789823211703402
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
        uint /*4*/[] memory input
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
