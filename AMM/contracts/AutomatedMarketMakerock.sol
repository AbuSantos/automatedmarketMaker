// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./IERC20.sol";

contract AutomatedMarkteMaker {
    IERC20 public immutable i_token0;
    IERC20 public immutable i_token1;

    //keeping a track of the tokens in the contract
    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;
    //mapping of the total share per user
    mapping(address => uint) public balanceOf;

    //the constructor takes in the address of the two ken to be swapped
    constructor(address _token0, address _token1) {
        i_token0 = IERC20(_token0);
        i_token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(
        address _tokenIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        //the first require checks the validity of the inputed token
        require(
            _tokenIn == address(i_token0) || _tokenIn == address(i_token1),
            "invalid Token"
        );
        //We check for the amount in
        require(_amountIn > 0, "Amount should be greater than 0");

        //checking if the inputed token is token0 or token1
        // if the inputed token is token0, the bool reads true anD vice versa
        bool isToken0 = _tokenIn == address(i_token0);
        //created two local variables to check which is token0 or token 1

        // if the tokenin is token 0, the reserve0 is updatd and the reserve1 and is sent out,
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint reserveIn,
            uint reserveOut
        ) = isToken0
                ? (i_token0, i_token1, reserve0, reserve1)
                : (i_token1, i_token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // calculating the amount of token to be sent out
        //ydx /(x + dx)= dy
        //y, the amount of token locked in the contract
        // dx, the amount of token that came in
        // x, the amount of token in the reserve before the swap
        // calculating the sawpping fee(0.3%)
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);

        tokenOut.transfer(msg.sender, amountOut);
        _update(
            i_token0.balanceOf(address(this)),
            i_token1.balanceOf(address(this))
        );
    }

    function addLiquidity() external {}

    function removeLiquidity() external {}
}
