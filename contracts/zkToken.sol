// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IVerifier.sol";

contract zkToken {
    string public name = "zkToken";
    string public symbol = "ZKT";
    uint256 public totalSupply = 5000000; // 5 000 000
    uint256 public decimals = 0;

    IVerifier private senderVerifierAddr;
    IVerifier private receiverVerifierAddr;

    mapping(address => uint256[2]) private balanceHashes;

    /* name, symbol, totalSupply, decimals */
    constructor(address _senderVerifierAddr, address _receiverVerifierAddr) {
        senderVerifierAddr = IVerifier(_senderVerifierAddr);
        receiverVerifierAddr = IVerifier(_receiverVerifierAddr);
    }

    function balanceOf(address _to) external view returns (uint256[2] memory) {
        return balanceHashes[_to];
    }

    // sha256(0)
    function balanceInitialization(address _to) internal {
        balanceHashes[_to][0] = 326522724692461750427768532537390503835;
        balanceHashes[_to][1] = 89059515727727869117346995944635890507;
    }

    // input = hashValue + hashReceiverBalanceAfter
    function mint(
        address _to,
        IVerifier.Proof memory proof,
        uint256[4] memory input
    ) external {
        uint256[2] memory hashReceiverBalanceBefore = balanceHashes[_to];

        if (
            hashReceiverBalanceBefore[0] == 0 &&
            hashReceiverBalanceBefore[1] == 0
        ) {
            balanceInitialization(_to);
            hashReceiverBalanceBefore = balanceHashes[_to];
        }

        bool receiverProofIsCorrect = receiverVerifierAddr.verifyTx(
            proof,
            [
                input[0],
                input[1],
                hashReceiverBalanceBefore[0],
                hashReceiverBalanceBefore[1],
                input[2],
                input[3]
            ]
        );

        // hashReceiverBalanceAfter
        if (receiverProofIsCorrect) balanceHashes[_to] = [input[2], input[3]];
        else revert("False Proof");
    }

    // input = hashValue + hashSenderBalanceAfter + hashReceiverBalanceAfter
    function transfer(
        address _to,
        IVerifier.Proof memory proofR,
        IVerifier.Proof memory proofS,
        uint256[6] memory input
    ) external {
        uint256[2] memory hashSenderBalanceBefore = balanceHashes[msg.sender];
        uint256[2] memory hashReceiverBalanceBefore = balanceHashes[_to];

        if (
            hashReceiverBalanceBefore[0] == 0 &&
            hashReceiverBalanceBefore[1] == 0
        ) {
            balanceInitialization(_to);
            hashReceiverBalanceBefore = balanceHashes[_to];
        }

        bool senderProofIsCorrect = senderVerifierAddr.verifyTx(
            proofS,
            [
                input[0],
                input[1],
                hashSenderBalanceBefore[0],
                hashSenderBalanceBefore[1],
                input[2],
                input[3]
            ]
        );
        bool receiverProofIsCorrect = receiverVerifierAddr.verifyTx(
            proofR,
            [
                input[0],
                input[1],
                hashReceiverBalanceBefore[0],
                hashReceiverBalanceBefore[1],
                input[4],
                input[5]
            ]
        );

        if (senderProofIsCorrect && receiverProofIsCorrect) {
            balanceHashes[msg.sender] = [input[2], input[3]];
            balanceHashes[_to] = [input[4], input[5]];
        } else revert("False Proofs");
    }
}
