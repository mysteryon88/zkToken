// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVerifier {
    function verifyTx(
        Proof memory proof,
        uint[6] memory input
    ) external view returns (bool r);

    struct G1Point {
        uint X;
        uint Y;
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    struct Proof {
        G1Point a;
        G2Point b;
        G1Point c;
    }
}
