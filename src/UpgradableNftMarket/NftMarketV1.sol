// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../EIP2612/NewNft.sol";
import "../EIP2612/NewToken.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
contract NftMarketV1 is TokenRecipient, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address tokenAddress;
    address nftAddress;

    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) seller;

    event Listed(address seller, uint256 price);
    event Sold(address seller, address buyer, uint256 price);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _tokenAddress,
        address _nftAddress,
        address initialOwner
    ) initializer public {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function tokenReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        uint256 nftId = abi.decode(data, (uint256));
        require(
            prices[nftId] <= amount,
            "payment value is less than list price"
        );
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
        NewToken(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            prices[nftId]
        );
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
        uint nftId,
        uint price,
        uint nounce,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        // check the signature if it is allowed to buy nft
        // if a guy can buy an nft, that is because this nft is listed, so we need a signature to list the nft
        // but after listing, how we make sure only the one with the signature can buy before anyother who saw the nft listed
        // 1. msg.sender shall approve address(this) to transfer token before the following logic
        // 2. use attacked digest to get approve to allow address(this) to get the nft
        // 3. then nftmarket check the transaction and conduct the transaction.abi

        NewNft(nftAddress).permit(
            from,
            to,
            nftId,
            price,
            nounce,
            deadline,
            v,
            r,
            s
        );

        prices[nftId] = price;
        seller[nftId] = from;
        emit Listed(from, price);

        NewToken(tokenAddress).transferFrom(msg.sender, address(this), price);
        NewToken(tokenAddress).transfer(from, price);

        NewNft(nftAddress).transferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }
}
