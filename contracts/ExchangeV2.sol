// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {

    IERC20 token;


    constructor(address _token){
        token= IERC20(_token);
    }
    function addLiquidity(uint256 _tokenAmount) public payable{
        token.transferFrom(msg.sender,address(this),_tokenAmount);

    }

    function ethToTokenSwap()public payable{
        uint256 inputAmount= msg.value;

        uint256 outputAmount= inputAmount;

        IERC20(token).transfer(msg.sender,outputAmount);
    }
    function getPrice(uint256 inputReserve,uint256 outputReserve)public pure returns (uint256){

        uint256 numerator= inputReserve;
        uint256 denominator= outputReserve;
        return numerator/denominator;
    }
//cpmm


/*
cpmm

초기유동성

1000 4000
2000 2000

4000- (4000+1000)/1000+1000
 */
 //가격츠겆ㅇ
    function getOutputAmount(uint256 inputAmount, uint256 inputReserve,uint256 outputReserve)public pure returns (uint256){

        uint256 numerator= outputReserve*inputAmount;
        uint256 denominator= inputReserve*inputAmount;
        return numerator/denominator;
    }
    
 //ETH->ERC20
  function ethToTokenSwap2(uint256 _minTokens)public payable{

        uint256 outputAmount= getOutputAmount(msg.value, address(this).balance-msg.value, token.balanceOf(address(this)));
        require(outputAmount>= _minTokens,"Inffucient outputamount");
        IERC20(token).transfer(msg.sender,outputAmount);
    }
}