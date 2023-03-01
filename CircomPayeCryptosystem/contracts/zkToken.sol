// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IVerifier.sol";

contract zkToken {
    string public name = "zkToken";
    string public symbol = "ZKT";
    uint256 public decimals = 0;

    IVerifier private senderVerifierAddr;
    IVerifier private registrationVerifierAddr;

    struct Key {
        uint256 n;
        uint256 g;
    }

    struct User {
        uint256 encryptedBalance;
        Key key;
    }

    mapping(address => User) private users;

    /* name, symbol, decimals */
    constructor(
        address _senderVerifierAddr,
        address _registrationVerifierAddr
    ) {
        senderVerifierAddr = IVerifier(_senderVerifierAddr);
        registrationVerifierAddr = IVerifier(_registrationVerifierAddr);
    }

    function balanceOf(address _to) external view returns (uint256) {
        return users[_to].encryptedBalance;
    }

    // для регистрации нужно создание еще одного доказательства
    /* onlyFee */
    function registration(User memory user) external payable /* onlyFee */ {
        require(user.encryptedBalance >= 0, "wrong balance value");
        require(user.key.g >= 0 && user.key.n >= 0, "invalid key value");
        users[msg.sender] = user;
    }

    function mint(
        address _to,
        IVerifier.Proof memory proof,
        uint256[4] memory input
    ) external {
        User storage user = users[_to];
    }

    function transfer(
        address _to,
        IVerifier.Proof memory proofR,
        uint256[6] memory input
    ) external payable /* onlyFee */ {}

    modifier onlyFee() {
        require(msg.value >= 0.001 ether, "Not enough fee!");
        _;
    }
}
