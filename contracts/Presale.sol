pragma solidity >=0.4.2 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Presale is Context, Ownable {
  address payable _withdrawalWallet;
  uint256 _rate;
  uint _startTime;
  uint _endTime;

  modifier onlyWithdrawalAddress() {
    require(
      _msgSender() == _withdrawalWallet, 
      "Error: Only withdrawal address can call this function"
    );
    _;
  }

  event RateChanged(uint256 newRate);

  constructor(
    address payable withdrawalWallet_, 
    uint256 rate_
  ) Ownable() public {
    _withdrawalWallet = withdrawalWallet_;
    _rate = rate_;
  }

  function _setRate(uint256 rate_) private returns (bool) {
    require(rate > 0, "Error: Rate must be greater than 0");
    _rate = rate_;
    emit RateChanged(rate_);
    return true;
  }

  function setRate(uint rate_) 
  external onlyWithdrawalAddress() returns (bool) {
    return _setRate(rate_)
  }
}