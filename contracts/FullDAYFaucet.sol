pragma solidity ^0.4.19;


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


contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
    require(SafeMath.sub(now,lastRequest[msg.sender]) >= waitTime);
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
