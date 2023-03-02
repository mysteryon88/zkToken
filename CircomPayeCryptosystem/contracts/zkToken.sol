// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IVerifier.sol";

contract zkToken {
    string public name = "zkToken";
    string public symbol = "ZKT";
    uint256 public decimals = 0;

    IVerifier private senderVerifierAddr;
    IVerifier private registrationVerifierAddr;
    IVerifier private mintVerifierAddr;

    struct Key {
        uint256 g;
        uint256 n;
    }

    struct User {
        uint256 encryptedBalance;
        Key key;
    }

    mapping(address => User) private users;

    /* name, symbol, decimals */
    constructor(
        address _senderVerifierAddr,
        address _registrationVerifierAddr /*,
        address _mintVerifierAddr*/
    ) {
        senderVerifierAddr = IVerifier(_senderVerifierAddr);
        registrationVerifierAddr = IVerifier(_registrationVerifierAddr);
        //mintVerifierAddr = IVerifier(_mintVerifierAddr);
    }

    function balanceOf(address _to) external view returns (uint256) {
        return users[_to].encryptedBalance;
    }

    /* onlyFee */
    function registration(
        User memory user,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[4] memory input
    ) external payable /* onlyFee */ {
        require(user.encryptedBalance >= 0, "wrong balance value");
        require(user.key.g >= 0 && user.key.n >= 0, "invalid key value");

        bool registrationProofIsCorrect = registrationVerifierAddr
            .verifyRegistrationProof(a, b, c, input);
        if(registrationProofIsCorrect)
            users[msg.sender] = user;
        else revert("Wrong Proof");
       
    }

    function mint(address _to) external {}

    function transfer(address _to) external payable /* onlyFee */ {

    }

    modifier onlyFee() {
        require(msg.value >= 0.001 ether, "Not enough fee!");
        _;
    }
}
