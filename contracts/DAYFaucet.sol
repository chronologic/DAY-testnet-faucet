pragma solidity^0.4.19;

import 'zeppelin/math/SafeMath.sol';
import 'zeppelin/ownership/Ownable.sol';
import * as Token from 'tokens/Token.sol';

contract DAYFaucet is Ownable{

  uint public waitTime = 3600; //Wait time in seconds to reques new tokens
  uint public allowedTokens = 100*1 ether; //Number of tokens granted per request
  address public tokenAddress;

  mapping(address=>uint) public lastRequest;//Timestamp address last withdrew from faucet

  event AllowedTokensUpdated(uint previous, uint updated,uint timestamp);//Event fired once the allowedtokens value is changed
  event WaitTimeUpdated(uint previous, uint updated,uint timestamp);//Event fired once the waitTime value is changed
  event AddressFunded(address indexed receiver, uint value,uint timestamp);//Event fired once the waitTime value is changed

  function DAYFaucet(address _dayAddress,uint _allowedTokens,uint _waitTime) public {
      tokenAddress = _dayAddress;
      updateAllowedTokens(_allowedTokens);
      updateWaitTime(_waitTime);
  }

  function getLastRequest(address _addr) public view returns (uint){
    return lastRequest[_addr];
  }

  //Retreive number of tokens owned by the contract
  function getTokensBalance() public view returns (uint balance){
    return Token(tokenAddress).balanceOf(this);
  }

  //Update tokens allowed by the contract
  function updateAllowedTokens(uint _value) public onlyOwner{
    if(_value>0){
      uint prev = allowedTokens;
      allowedTokens = _value;
      AllowedTokensUpdated(prev,allowedTokens,block.timestamp);
    }
  }

  //Update tokens allowed by the contract
  function updateWaitTime(uint _value) public onlyOwner{
      if(_value>0){
        uint prev = waitTime;
        waitTime = _value;
        WaitTimeUpdated(prev,allowedTokens,block.timestamp);
      }
  }

  //Actuall faucet function
  function useFaucet() public{
    require(SafeMath.sub(now,getLastRequest(msg.sender)) >= waitTime);
    require(getTokensBalance() >= allowedTokens );
    lastRequest[msg.sender] = now;
    AddressFunded(msg.sender, allowedTokens, now);
    Token(tokenAddress).transfer(msg.sender,allowedTokens);
  }

  //Retreive allowed funds from the contract to the owner
  function withdraw() public {
    Token(tokenAddress).transfer(owner,getTokensBalance());
    if(this.balance>0)
      owner.transfer(this.balance);
  }

  //Allow Retreival of indicated tokens from the contract to the owner
  function withdraw(address _addr) public {
    Token token = Token(_addr);
    uint bal = token.balanceOf(this);
    token.transfer(owner,bal);
  }

  function() public {
    useFaucet();
  }
}
