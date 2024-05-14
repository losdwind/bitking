pragma solidity 0.8.25;

interface IUniswapV1Factory {
    function getExchange(address) external view returns (address);
}
