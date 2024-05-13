// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../EIP2612/NewNft.sol";
import "../EIP2612/NewToken.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "forge-std/console.sol";

contract AirDropNftMarket is TokenRecipient {
    bytes32 public merkleRootHash;
    address tokenAddress;
    address nftAddress;

    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) seller;

    event Listed(address seller, uint256 price);
    event Sold(address seller, address buyer, uint256 price);

    error DelegatecallFailed();

    constructor(address _tokenAddress, address _nftAddress, bytes32 merkleRootHash_) {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
        merkleRootHash = merkleRootHash_;
    }

    function tokenReceived(address sender, uint256 amount, bytes calldata data) external returns (bool) {
        uint256 nftId = abi.decode(data, (uint256));
        require(prices[nftId] <= amount, "payment value is less than list price");
        NewToken(tokenAddress).transfer(seller[nftId], prices[nftId]);
        NewNft(nftAddress).safeTransferFrom(address(this), sender, nftId);
        emit Sold(seller[nftId], sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

    function list(uint256 nftId, uint256 price) external returns (bool) {
        // NewNft(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);
        NewNft(nftAddress).transferFrom(msg.sender, address(this), nftId);

        prices[nftId] = price;
        seller[nftId] = msg.sender;
        emit Listed(msg.sender, price);
        return true;
    }

    function buyNFT(uint256 nftId) external returns (bool) {
        NewToken(tokenAddress).transferFrom(msg.sender, address(this), prices[nftId]);
        NewToken(tokenAddress).transfer(seller[nftId], prices[nftId]);
        NewNft(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

    function permitBuy(
        address from,
        address to,
        uint256 nftId,
        uint256 price,
        uint256 nounce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        NewNft(nftAddress).permit(from, to, nftId, price, nounce, deadline, v, r, s);

        prices[nftId] = price;
        seller[nftId] = from;
        emit Listed(from, price);

        NewToken(tokenAddress).transferFrom(msg.sender, address(this), price);
        NewToken(tokenAddress).transfer(from, price);

        NewNft(nftAddress).transferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
    }

    function multiDelegatecallBuy(bytes[] memory data) external {
        for (uint256 i; i < data.length; i++) {
            (bool ok,) = address(this).delegatecall(data[i]);
            // if (!ok) {
            //     revert DelegatecallFailed();
            // }
        }
    }

    function permitPrePay(
        address from,
        address to,
        uint256 nftId,
        uint256 price,
        uint256 nounce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        NewNft(nftAddress).permit(from, to, nftId, price, nounce, deadline, v, r, s);
        prices[nftId] = price;
        seller[nftId] = from;
        emit Listed(from, price);
    }

    function claimNFT(address from, uint256 nftId, bytes32[] calldata merkleHashes) public {
        verify(merkleHashes, merkleRootHash, from);
        uint256 finalPrice = prices[nftId] / 2;

        NewToken(tokenAddress).transferFrom(msg.sender, address(this), finalPrice);
        NewToken(tokenAddress).transfer(from, finalPrice);

        NewNft(nftAddress).transferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
    }

    function verify(bytes32[] memory proof, bytes32 root, address addr) public {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, 1))));
        console.logBytes32(proof[0]);
        console.logBytes32(proof[1]);

        console.logBytes32(root);
        console.logBytes32(leaf);
        require(MerkleProof.verify(proof, root, leaf), "Invalid proof");
    }
}
