// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./9_ERC721.sol";
import "./8_ERC_20_Extended.sol";

contract NftMarket is TokenRecipient {
    address tokenAddress;
    address nftAddress;

    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) seller;

    constructor(address _tokenAddress, address _nftAddress) {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }

    function tokenReceived(address sender, uint256 amount, bytes calldata data) external returns (bool) {
        uint nftId = abi.decode(data, (uint));
        require(prices[nftId] <= amount, "payment value is less than list price");
        BaseERC20(tokenAddress).transfer(seller[nftId], prices[nftId]);
        AJNFT(nftAddress).safeTransferFrom(address(this), sender, nftId);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

    function list(uint256 nftId, uint256 price) external returns (bool) {
        // AJNFT(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);
        AJNFT(nftAddress).transferFrom(msg.sender, address(this), nftId);

        prices[nftId] = price;
        seller[nftId] = msg.sender;
        return true;
    }

    function buyNFT(uint256 nftId) external returns (bool) {
        BaseERC20(tokenAddress).transferFrom(msg.sender, address(this), prices[nftId]);
        BaseERC20(tokenAddress).transfer(seller[nftId], prices[nftId]);
        AJNFT(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }
}
