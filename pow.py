import hashlib
import time

def mine(prefix_name, difficulty):
    nonce = 0
    start_time = time.time()
    prefix_zeros = '0' * difficulty
    while True:
        # 创建待哈希的字符串
        input_str = f'{prefix_name}{nonce}'
        # 计算哈希值
        hash_result = hashlib.sha256(input_str.encode()).hexdigest()
        # 检查哈希值是否满足条件
        if hash_result.startswith(prefix_zeros):
            time_spent = time.time() - start_time
            print(f"Nonce: {nonce}")
            print(f"Hash: {hash_result}")
            print(f"Time spent: {time_spent:.4f} seconds")
            break
        nonce += 1

# 使用自己的昵称
nickname = "ajs"
print("Mining for 4 leading zeros:")
mine(nickname, 4)
print("Mining for 5 leading zeros:")
mine(nickname, 5)
print("Mining for 6 leading zeros:")
mine(nickname, 6)