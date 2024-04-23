// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "contracts/9_ERC721.sol";
import "contracts/8_ERC_20_Extended.sol";

contract NftMarket {

    address tokenAddress;
    address nftAddress;

    mapping(uint => uint) prices;
    mapping(uint => address) seller;

    constructor(address _tokenAddress, address _nftAddress){
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }

    function list(uint nftId, uint price) external returns(bool) {
        // AJNFT(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);
        AJNFT(nftAddress).transferFrom(msg.sender, address(this), nftId);

        prices[nftId] = price;
        seller[nftId] = msg.sender;
        return true;
    }

    function buyNFT(uint nftId) external returns(bool) {
        BaseERC20(tokenAddress).transferFrom(msg.sender, address(this), prices[nftId]);
        BaseERC20(tokenAddress).transfer(seller[nftId], prices[nftId]);
        AJNFT(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

}