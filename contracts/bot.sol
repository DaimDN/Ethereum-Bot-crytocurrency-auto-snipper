// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSniper {
    address public owner;
    IUniswapV2Router public uniswapRouter;
    address public WETH;
    address public targetToken;

    event Sniped(uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _uniswapRouter, address _WETH, address _targetToken) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        WETH = _WETH;
        targetToken = _targetToken;
    }

    function snipe() external payable onlyOwner {
        uint256 amountETH = msg.value;
        require(amountETH > 0, "Insufficient ETH");

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = targetToken;

        uniswapRouter.swapExactETHForTokens{ value: amountETH }(
            0, // Accept any amount of Tokens
            path,
            address(this),
            block.timestamp + 300
        );

        uint256 tokenBalance = IERC20(targetToken).balanceOf(address(this));
        emit Sniped(tokenBalance);
    }

    function withdrawTokens(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function withdrawETH(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    receive() external payable {}
}
