import hashlib
import random
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import serialization

def generate_keys():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    public_key = private_key.public_key()
    return private_key, public_key

def mine_proof_of_work(prefix, difficulty):
    nonce = 0
    prefix_zeros = '0' * difficulty
    while True:
        text = f'{prefix}{nonce}'
        hash_result = hashlib.sha256(text.encode()).hexdigest()
        if hash_result.startswith(prefix_zeros):
            return text, hash_result
        nonce += 1

def sign_data(private_key, data):
    signature = private_key.sign(
        data.encode(),
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    return signature

def verify_signature(public_key, data, signature):
    try:
        public_key.verify(
            signature,
            data.encode(),
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except Exception as e:
        return False

# Main execution
nickname = "ajs"
difficulty = 4

# Generate RSA keys
private_key, public_key = generate_keys()

# Mine a valid nonce with PoW
data, valid_hash = mine_proof_of_work(nickname, difficulty)
print(f'Mined data: {data}')
print(f'Valid hash: {valid_hash}')

# Sign the valid hash using the private key
signature = sign_data(private_key, valid_hash)
print(f'Signature: {signature.hex()}')

# Verify the signature using the public key
verification_result = verify_signature(public_key, valid_hash, signature)
print(f'Verification result: {verification_result}')
