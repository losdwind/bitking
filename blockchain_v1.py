import hashlib
import time
from flask import Flask, jsonify, request
import requests

class Blockchain():
    def __init__(self):
        self.current_transactions = []
        self.chain = []
        self.nodes = set()

    def register_node(self, node):
        self.nodes.add(node)
    
    def resolve_conflicts(self) -> bool:
        max_length = len(self.chain)
        new_chain = None
        for node in self.nodes:
            response = requests.get(f'http://{node}/chain')
            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']
            if length > max_length and self.valid_chain(chain):
                max_length = length
                new_chain = chain

        if new_chain:
            self.chain = new_chain
            return True
        return False
    
    def valid_chain():
        pass

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

    def valid_proof(previous_proof, proof) -> bool:
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
    previous_hash = last_block['previous_hash']

    blockchain.new_transaction(sender="0", recipient='', amount=50)

    blockchain.mine(previous_hash=previous_hash)

    new_block = blockchain.chai[-1]
    response = {
        'message': 'New Block Forged',
        'index': new_block['index'],
        'timestamp': new_block['timestamp'],
        'proof': new_block['proof'],
        'previous_hash': new_block['previous_hash']
    }

    return jsonify(response), 200



@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.get_json()

    required = ['sender', 'recipient', 'amount']

    if not all(require in values for require in required):
        return "missing values", 400
    
    blockchain.new_transaction(
        sender=values.sender,
        recipient=values.recipient,
        amount = values.amount
    )

    response = {'message': f'transaction will be added to block {blockchain.chain['index']+1}'}
    return jsonify(response), 201


@app.route('/chain')
def chain():
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain)
    }

    return jsonify(response), 200


@app.route('/node/register', methods=['POST'])
def register_node():
    values = request.get_json()
    nodes = values.get('nodes')
    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400
    
    for node in nodes:
        blockchain.register_node(node)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': list(blockchain.nodes)
    }

    return jsonify(response), 201

@app.route('/nodes/resolve')
def consensus():
    replaced = 