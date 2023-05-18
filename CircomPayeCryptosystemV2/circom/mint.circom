pragma circom 2.1.3;

include "binpower.circom";

template Main() {
	signal input encryptedValue;
	signal input value;
	// PubKey = g, r, n
	signal input receiverPubKey[3];

	signal input encryptedreceiverBalance;
	signal input newEncryptedreceiverBalance;

	// value cannot be negative
	assert(value > 0);

	// payment encryption check
	component pow1 = Binpower();
	component pow2 = Binpower();

	pow1.b <== receiverPubKey[0];
	pow1.e <== value;
	pow1.modulo <== receiverPubKey[2] * receiverPubKey[2];

	pow2.b <== receiverPubKey[1];
	pow2.e <== receiverPubKey[2];
	pow2.modulo <== receiverPubKey[2] * receiverPubKey[2];

	signal enValue <-- (pow1.out * pow2.out) % (receiverPubKey[2] * receiverPubKey[2]);
	encryptedValue === enValue;

	// verification of the correctly calculated new balance of the recipient
	signal enNewEncryptedreceiverBalance <-- (encryptedreceiverBalance * encryptedValue) % (receiverPubKey[2] * receiverPubKey[2]);

	newEncryptedreceiverBalance === enNewEncryptedreceiverBalance;
}

// public data
component main {
		public [encryptedValue,				// sender calculates
				receiverPubKey,				// in storage + rand r
				encryptedreceiverBalance,	// in storage
				newEncryptedreceiverBalance] // sender calculates
				} = Main();

