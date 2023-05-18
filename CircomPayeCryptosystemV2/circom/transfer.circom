pragma circom 2.1.3;

include "binpower.circom";

template Main() {
    signal input encryptedSenderBalance;
	signal input newEncryptedSenderBalance;

	signal input encryptedValue;
	signal input value;

	// PubKey = g, rand r, n
	signal input senderPubKey[3];
	signal input receiverPubKey[3];
	// l, mu, n
	signal input senderPrivKey[3];

	signal input encryptedReceiverBalance;
	signal input newEncryptedReceiverBalance;

	// value cannot be negative
	assert(value > 0);

	// deciphering the old sender balance 
	component pow1 = Binpower();
	
	pow1.b <== encryptedSenderBalance;
	pow1.e <== senderPrivKey[0];
	pow1.modulo <== senderPrivKey[2] * senderPrivKey[2];

	signal senderBalance <-- (pow1.out - 1) / senderPrivKey[2] * senderPrivKey[1] % senderPrivKey[2];

	// checking that the current balance is greater than the payment amount
	assert(senderBalance >= value);

	// payment encryption check
	component pow3 = Binpower();
	component pow4 = Binpower();

	pow3.b <== receiverPubKey[0];
	pow3.e <== value;
	pow3.modulo <== receiverPubKey[2] * receiverPubKey[2];

	pow4.b <== receiverPubKey[1];
	pow4.e <== receiverPubKey[2];
	pow4.modulo <== receiverPubKey[2] * receiverPubKey[2];

	signal enValue <-- (pow3.out * pow4.out) % (receiverPubKey[2] * receiverPubKey[2]);
	encryptedValue === enValue;

	// checking the correctness of the new balance
	component pow5 = Binpower();
	component pow6 = Binpower();

	pow5.b <== senderPubKey[0];
	pow5.e <== senderBalance - value;
	pow5.modulo <== senderPubKey[2] * senderPubKey[2];

	pow6.b <== senderPubKey[1];
	pow6.e <== senderPubKey[2];
	pow6.modulo <== senderPubKey[2] * senderPubKey[2];

	signal enNewEncryptedSenderBalance <-- (pow5.out * pow6.out) % (senderPubKey[2] * senderPubKey[2]);
	newEncryptedSenderBalance === enNewEncryptedSenderBalance;

	// verification of the correctly calculated new balance of the recipient
	signal enNewEncryptedReceiverBalance <-- (encryptedReceiverBalance * encryptedValue) % (receiverPubKey[2] * receiverPubKey[2]);

	newEncryptedReceiverBalance === enNewEncryptedReceiverBalance;
}

// public data
component main {
		public [encryptedSenderBalance, 	// in storage
				newEncryptedSenderBalance,	// sender calculates 
				encryptedValue,				// sender calculates
				senderPubKey, 				// in storage + rand r
				receiverPubKey,				// in storage + rand r
				encryptedReceiverBalance,	// in storage
				newEncryptedReceiverBalance]	// sender calculates
				} = Main();