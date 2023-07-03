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

    function addLiquidity(
        uint _amount0,
        uint _amount1
    ) external returns (uint shares) {
        i_token0.transferFrom(msg.sender, address(this), _amount0);
        i_token1.transferFrom(msg.sender, address(this), _amount1);

        //checking to see the amoiuntv of token sent in so not to distabilize the contract
        // dy/dx =y/x
        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "dy/dx != y/x");
        }

        //Mint shares
        // for the shares to mint, their are two parts, if totalshares is equal to 0 and when totalshares is greater than 0
        // f=(x,y) =value of Liquidity = sqrt(xy)
        // shares = dx/x * t = dy/y*t where T= total supply

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }

        require(shares > 0, "Shares is less than 0");
        _mint(msg.sender, shares);
        _update(
            i_token0.balanceOf(address(this)),
            i_token1.balanceOf(address(this))
        );
    }

    function removeLiquidity() external {}

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // returns the minimum between x and y

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}
