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
            7067958108356785074600476904767658253614953318245590283940455182182249164476,
            6056276134098406242160271476475778446028153426982301964255105976099273750178
        );

        vk.beta2 = Pairing.G2Point(
            [
                19106950520377209480978658280912359175192508875116974348103688006810107789943,
                19359698801014396007620988293283352639895997339670983327460689436451515357171
            ],
            [
                16921656458691377728718812306764044979920046320337978372990091035013522754561,
                15158390326358269893743441401060690956784170993362779849443634859472732637673
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
                5767430856614847005571553183993747259522195247966719459524011703991451684697,
                914045813903215648550868002834377591994223239587957146136316579431672424884
            ],
            [
                2098532084001143422869462717497879043119267687457876070345478659269552348230,
                10284145477345585331397642867031281754004192588332209051420912510762934684668
            ]
        );
        vk.IC = new Pairing.G1Point[](10);

        vk.IC[0] = Pairing.G1Point(
            470115324011893081829976987763339973681011365108383992491581923676313039871,
            20985319245254198884385631134109509095080496301965328864004414665767893964647
        );

        vk.IC[1] = Pairing.G1Point(
            17978072060171079198493945900429036751265309977053911852795453541911335258932,
            2426099076076979205028073145039720860556249880278952666098032360803867203413
        );

        vk.IC[2] = Pairing.G1Point(
            5538752466897536723445884106975646506790479737951886493480533318050431690685,
            5101922331342641944661458051910432205178562049821392134524114779288992522650
        );

        vk.IC[3] = Pairing.G1Point(
            16028097778756391215365163591270865323464883793733040479575446257797425579702,
            2550885626186301427382949943579898945060925564811152619427085164387599485975
        );

        vk.IC[4] = Pairing.G1Point(
            9507104010997891323593134490460399704032572398156965060924464328363451849847,
            17889912065101637037949442969936192313531115128205042579055872018605762138951
        );

        vk.IC[5] = Pairing.G1Point(
            14478142289834620528028645719796094496625069642987083925170574342643761627196,
            5551136416230058398673296841192548018036721697825348644665751375503247443817
        );

        vk.IC[6] = Pairing.G1Point(
            21578578445488503866216827627233212742050340188763581360029982699885144475633,
            16795063871026229518946952647466951559269056241878490728094421253107255825013
        );

        vk.IC[7] = Pairing.G1Point(
            15360504677513311159068685593984869005054938916425713820438310098221040345191,
            16304990365263542169878484601395331436180243598638916821073027845494509579210
        );

        vk.IC[8] = Pairing.G1Point(
            6138814283427884819570107427054912355557866553879030589382538510371203518317,
            15183152815963757422615383151633848656791282560438071204073415482465156652329
        );

        vk.IC[9] = Pairing.G1Point(
            1138513353873069530834402424728930697772591898016069513368958081137916242304,
            8329473992838476235853261057083922352799749931966796577130832653061324053903
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
        uint /*9*/[] memory input
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
