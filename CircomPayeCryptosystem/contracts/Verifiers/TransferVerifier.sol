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
            5384889026507950307230758197264469676693077494570201291361561711020732239926,
            21562893387904089995490724141786395164344623965778817309625399038393242610479
        );

        vk.beta2 = Pairing.G2Point(
            [
                18387238095259841939347376194661721130497115919546658136298744047963172819463,
                15142228850399776841690601407428644862609982720844435886227865225907172014607
            ],
            [
                19394940280887772840044711029251880188494907577723071903069836095980014834760,
                14175845661034502147992553663018031868654465689768505192255659336671157478044
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
                3511902301385464320323978750027685155594700883640109627580814935837930361218,
                20739666017448903934359154444098819311310745922976894986181562985475488738065
            ],
            [
                14128483137876211730860704360626228675522123582614246942195912414994584530399,
                7990657760650849306812758238132216003594474132212539086697245738625991671349
            ]
        );
        vk.IC = new Pairing.G1Point[](10);

        vk.IC[0] = Pairing.G1Point(
            1530407160911595925507814784514842636776680555771756172570292464602197263234,
            16993582891588733859457115531484772706367530181802673170340615197784435935901
        );

        vk.IC[1] = Pairing.G1Point(
            3793419378880495303867626050331866713621419176845188543123843955432596011489,
            15812945972063308088002821614342457664929040310933911217447933779332819156104
        );

        vk.IC[2] = Pairing.G1Point(
            2540692616203864877552123101486268539159709072141184590222540737966172171894,
            17366531157297575474991375588895827841244833612324864240851737829970402705965
        );

        vk.IC[3] = Pairing.G1Point(
            12591786070202001383152903456024347214878594301216235029736352552057168902301,
            9532810965769615111204215191270044891483731352796809857236859444470157709578
        );

        vk.IC[4] = Pairing.G1Point(
            17696400238197234743203680229540780851949882812270445154315988220555598739031,
            9701574679787297722263250219827057832679049288670517670745082226917922523288
        );

        vk.IC[5] = Pairing.G1Point(
            981872542600359697288026641310635129958923699155106140542411099860693835033,
            11102001260271133947665352741181531593938827894865773417232122871266839922811
        );

        vk.IC[6] = Pairing.G1Point(
            12666789303806029269651330939788025632553361582190113485045753247934594525752,
            8147780516866090576809336816946379931516308992642286505291316776104805106094
        );

        vk.IC[7] = Pairing.G1Point(
            5452277082781801671328608123284848789492959331634457887819066406869396237963,
            12077485927794209168529919049489212895686558826562481493225931604085349863080
        );

        vk.IC[8] = Pairing.G1Point(
            15781947611514211663951561791611392571345099086194110592678439950991095028502,
            14003192912625217570936052456957998119485904544448184745210675956545053539982
        );

        vk.IC[9] = Pairing.G1Point(
            18613357880466618139543804832934045168112816818552814875507871787050466757549,
            8753814439170088596976114800715135202254351199403626837967683996072801339394
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
    function verifyTransferProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[9] memory input
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
