// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IFactory.sol";
contract Exchange is ERC20{

    IERC20 token;
    IFactory factory;

    constructor(address _token)ERC20("Gray Uniswap V2","GUNI-V2"){
        token= IERC20(_token);
        factory= IFactor(msg.sender);
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

    /*
    유동성 공급자가 유동성을 제거할떄는 LP토큰을 소각하고 ETH와 토큰을 돌려받는다

    돌려받는 ETH와 토큰의 개수는 내가 회수하고자 하는 LP토큰의 개수와 전체 풀의 비율만큼 돌려받는다
     */
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
    //가격측정
    function getOutputAmount(uint256 inputAmount, uint256 inputReserve,uint256 outputReserve)public pure returns (uint256){

        uint256 numerator= outputReserve*inputAmount;
        uint256 denominator= inputReserve*inputAmount;
        return numerator/denominator;
    }
    
      /*
   트레이더가 지급한 수수료만큼 유동성 풀의 토큰 개수가 증가
     트레이더에게 수수료를 제외하고 토큰을 스왑해준다
     예를들어 100개의 토큰을 input으로 넣엇는데 99개의 inputAmount로 OutputAmount를 계산한다
    그만큼 OutputAmount가 줄어들어 내가 받게 되는 토큰의 개수가 줄어든다
    OutputAmount수수료만큼 Output에 해당하는 토큰의 Reserve가 증가하는 효과가 있다.
    */  
    function getOutputAmountWithFee(uint256 inputAmount, uint256 inputReserve,uint256 outputReserve)public pure returns (uint256){
        uint256 inputAmountWithFee= inputAmount *99;
        uint256 numerator= inputAmountWithFee*outputReserve;
        uint256 denominator= (inputReserve*100+inputAmountWithFee);
        return numerator/denominator;
    }
    
    
 //ETH->ERC20
  function ethToTokenSwap2(uint256 _minTokens)public payable{

        // uint256 outputAmount= getOutputAmount(msg.value, address(this).balance-msg.value, token.balanceOf(address(this)));

        uint256 outputAmount= getOutputAmountWithFee(msg.value, address(this).balance-msg.value, token.balanceOf(address(this)));
        require(outputAmount>= _minTokens,"Inffucient outputamount");
        IERC20(token).transfer(msg.sender,outputAmount);
    }
    
 //ERC20->ETH
  function tokenToEthSwap(uint256 _tokenSold,uint256 _minEth)public payable{
        // uint256 outputAmount= getOutputAmount(_tokenSold,token.balanceOf(address(this)),address(this).balance);

        uint256 outputAmount= getOutputAmountWithFee(_tokenSold,token.balanceOf(address(this)),address(this).balance);
        require(outputAmount>= _minEth,"Inffucient outputamount");
        IERC20(token).transferFrom(msg.sender, address(this),_tokenSold);
        payable(msg.sender).transfer(outputAmount);
    }
    

    /*비영구적 손실
    
    - 유동성 풀에 공급한 나의 유동성의 자산 해당하는 가치변화
    - 유동성 공급을 하지 않고 토큰을 그냥 가지고 있는 것과 유동성 공급 후 다시 회수 했을 떄 받게 되는 토큰 개수의 변화
     */




  
}