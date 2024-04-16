import hashlib
import time
from flask import Flask

class Blockchain():
    def __init__(self):
        self.current_transactions = []
        self.chain = []

    def last_block(self):
        return self.chain[-1]

    def mine(self,previous_hash):

        proof = self.proof_of_work(previous_hash)

        block = {
            "index":  + 1,
            "timestamp": time.time(),
            "transactions": self.current_transactions,
            "proof": proof
        }

        self.chain.append(block)


    def new_transaction(self, sender, recipient, amount):
        self.current_transactions.append({
            "sender": sender,
            "recipient": recipient,
            "amount": amount
        })
        
    
    def proof_of_work(self, previous_hash):
        proof = 0
        while self.valid_proof(previous_hash, proof) is False:
            proof += 1

        return proof

    def valid_proof(previous_proof, proof):
        # check the hash of {previous_proof}{proof} meets the difficulty

        # get the data to be checked
        data = str(previous_proof) + str(proof)

        # define the difficulty
        difficulty = "00000"
        
        # get the hashed data
        hashed_data = hash(data)

        # check 
        if hashed_data.startswith(difficulty):
            return True
        else:
            return False

    def hash(data):
        return hashlib.sha256(data).hexdigest()
    
app = Flask(__name__)
blockchain = Blockchain()

@app.route('/')
def mine():
    last_block = blockchain.last_block()
    previous_hash = last_block['proof']
    blockchain.mine()

@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    blockchain.new_transaction()

@app.route('/')
