// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20{

    IERC20 token;


    constructor(address _token)ERC20("Gray Uniswap V2","GUNI-V2"){
        token= IERC20(_token);
    }
    //cpmm
    //LP토큰발행
    function addLiquidity(uint256 _maxTokens) public payable{
        //전체 유틸리니
        uint256 totalLiquidity= totalSupply();
        uint256 ethReserve= address(this).balance- msg.value;
        uint256 tokenReserve= token.balanceOf(address(this));
        uint256 tokenAmount= msg.value * tokenReserve /ethReserve;
        require(_maxTokens  >= tokenAmount);
        token.transferFrom(msg.sender, address(this), tokenAmount);
        uint256 liquidityMinted= totalLiquidity * msg.value/ethReserve;
        _mint(msg.sender,liquidityMinted);
        if (totalLiquidity>0){
//유동성 0인경우
        }else{
      uint256 tokenAmount= _maxTokens;
      uint256 initalLiquidity= address(this).balance;
      _mint(msg.sender,initalLiquidity);

        token.transferFrom(msg.sender,address(this),tokenAmount);
        }
      

    }
   function removeLiquidity(uint256 _lpTokenAmount)public{
    uint256 totalLiquidity= totalSupply();
    uint256 ethAmount= _lpTokenAmount*address(this).balance/totalLiquidity;
    uint256 tokenAmount= _lpTokenAmount * token.balanceOf(address(this))/totalLiquidity;

    _burn(msg.sender,_lpTokenAmount);
    payable(msg.sender).transfer(ethAmount);

    token.transfer(msg.sender, tokenAmount);
    
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
    
 //ERC20->ETH
  function tokenToEthSwap(uint256 _tokenSold,uint256 _minEth)public payable{

        uint256 outputAmount= getOutputAmount(_tokenSold,token.balanceOf(address(this)),address(this).balance);
        require(outputAmount>= _minEth,"Inffucient outputamount");
        IERC20(token).transferFrom(msg.sender, address(this),_tokenSold);
        payable(msg.sender).transfer(outputAmount);
    }
    
}