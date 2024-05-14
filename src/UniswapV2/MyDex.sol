// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {UniswapV2Router02} from "./Periphery/UniswapV2Router02.sol";
import {RNT} from "./RNT.sol";

contract MyDex {
    address payable router;
    address payable weth;
    address payable rnt;
    address pair;

    constructor(address _routerAddress, address _rnt, address _pair) {
        router = payable(_routerAddress);
        weth = payable(UniswapV2Router02(router).WETH());
        rnt = payable(_rnt);
        pair = _pair;
    }

    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = buyToken;

        UniswapV2Router02(router).swapExactETHForTokens{value: msg.value}(
            minBuyAmount, path, msg.sender, block.timestamp + 1 days
        );
    }

    function buyETH(address from, address sellToken, uint256 sellAmount, uint256 minBuyAmount) external {
        RNT(rnt).transferFrom(from, address(this), sellAmount);
        RNT(rnt).approve(router, sellAmount);
        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = weth;

        UniswapV2Router02(router).swapExactTokensForETH(sellAmount, minBuyAmount, path, from, block.timestamp + 1 days);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public payable {
        RNT(rnt).approve(router, amountTokenDesired);
        UniswapV2Router02(router).addLiquidityETH{value: msg.value}(
            token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline
        );
    }
}
