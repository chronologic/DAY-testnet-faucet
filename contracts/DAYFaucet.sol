pragma solidity ^0.4.19;

import "./HumanStandardToken.sol";

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

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

  //Retreive number of tokens owned by the contract
  function getTokensBalance() public view returns (uint balance){
    return HumanStandardToken(tokenAddress).balanceOf(this);
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
    require(SafeMath.sub(now,lastRequest[msg.sender]) >= waitTime);
    require(getTokensBalance() >= allowedTokens );
    lastRequest[msg.sender] = now;
    AddressFunded(msg.sender, allowedTokens, now);
    HumanStandardToken(tokenAddress).transfer(msg.sender,allowedTokens);
  }

  //Retreive allowed funds from the contract to the owner
  function withdraw() public {
    HumanStandardToken(tokenAddress).transfer(owner,getTokensBalance());
    if(this.balance>0)
      owner.transfer(this.balance);
  }

  //Allow Retreival of indicated tokens from the contract to the owner
  function withdraw(address _addr) public {
    Token token = HumanStandardToken(_addr);
    uint bal = token.balanceOf(this);
    token.transfer(owner,bal);
  }

  function() public {
    useFaucet();
  }
}
