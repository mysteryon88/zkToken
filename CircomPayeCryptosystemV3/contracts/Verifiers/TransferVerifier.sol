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
            15956834550190751168401990528531122336949739427363059813274991869985041133270,
            11029295299445985348187301935980075601069606081336645885925710885319213155928
        );

        vk.beta2 = Pairing.G2Point(
            [
                13077457010735586387063827588794462625596854742979272525128608673768553605677,
                6113150761966647234518013909890084896983635743550900167150263927696827729458
            ],
            [
                21234600562335324287983487857877239072088009701255119380433103427223843170626,
                13460615530358356888974409088467451679651364984608467443413065858359620984968
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
                21235358820888815807023095729912198113475732838876796136408440540692138148230,
                14548330959071494297075635525440574465359567360139598567360091575445457554074
            ],
            [
                12364703390192904742708494013699508719249924377304849185116445289898064076770,
                14509296614982925078036835487219495342490297295636450403233554536260921591685
            ]
        );
        vk.IC = new Pairing.G1Point[](10);

        vk.IC[0] = Pairing.G1Point(
            5591462473595494162777047603729005328167464099956660034555543976385240273458,
            8984166091870225671009913762357758065551275665024759952164174353187042660728
        );

        vk.IC[1] = Pairing.G1Point(
            3367322721600144829943202730721860952195955050461528401280412386581464968548,
            16949418136838372284933609459007679991934763451936563701305285992974709476458
        );

        vk.IC[2] = Pairing.G1Point(
            16416246140979952082557431189191576492008669194632180570750732570568837391443,
            14503076487102811714780076686225947964650505968640672829878144650530199307195
        );

        vk.IC[3] = Pairing.G1Point(
            8234873010668594213919887334609121647985228533495577387776791231086043151825,
            14130968947903502072580187444518329163729970008102006153159084754648943313687
        );

        vk.IC[4] = Pairing.G1Point(
            4226553717868393822516078121133810712447807713298236015791399713460892454102,
            20895934555066677196589683337179677235629827848848346225690068145146156874818
        );

        vk.IC[5] = Pairing.G1Point(
            16090962841979856800526033985747265294019527918831215809582525647535528205279,
            17933476465509357195480135606774486298207685751914480407708269270352238093040
        );

        vk.IC[6] = Pairing.G1Point(
            14989551234299076715445191427451206597468199197303015125489761332318045826485,
            3610027272176951385054871246274240761406033157149561328386231860944473624199
        );

        vk.IC[7] = Pairing.G1Point(
            19071046333040830855382355849728151854934870806868540635252655336794399567149,
            7257144423831773009321167320911752868994141348455353461292511456624834031897
        );

        vk.IC[8] = Pairing.G1Point(
            21455440381255349183125437974372077756717305539124905172274210711663155128902,
            19599258765108915013011484967802893035602311340729900036307083503548874353014
        );

        vk.IC[9] = Pairing.G1Point(
            13649812399070209425402498488017069933184753747228581403919429126667853420574,
            12218050682727325247165494189283236702243308717230381978954988334470421145202
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
