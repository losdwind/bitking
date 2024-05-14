pragma solidity 0.8.25;

interface IUniswapV2Migrator {
    function migrate(address token, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline)
        external;
}
