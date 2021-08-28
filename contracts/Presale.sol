pragma solidity >=0.4.2 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/IERC20.sol";

contract Presale is Context, Ownable {
  address payable _withdrawalWallet;
  uint256 _rate;
  uint _startTime;
  uint _endTime;
  bool _initialized = false;
  bool _finalized = false;
  IERC20 _tradeToken;

  modifier onlyWithdrawalAddress() {
    require(
      _msgSender() == _withdrawalWallet, 
      "Error: Only organization can call this function"
    );
    _;
  }

  event RateChanged(uint256 newRate)
  event PresaleStarted(uint256 startTime, uint256 endTime);
  event PresaleExtended(uint256 newEndTime);
  event PresaleFinalized(uint256 finalTime);
  event TokenSold(uint256 amount, address buyer);

  constructor(
    address withdrawalWallet_, 
    uint256 rate_,
    address token_
  ) Ownable() public {
    _withdrawalWallet = payable(withdrawalWallet_);
    _rate = rate_ * 1 ether;
    _tradeToken = IERC20(token_);
  }

  function _setRate(uint256 rate_) private returns (bool) {
    require(rate > 0, "Error: Rate must be greater than 0");
    _rate = rate_ * 1 ether;
    emit RateChanged(rate_);
    return true;
  }

  function setRate(uint rate_) 
    external onlyWithdrawalAddress() returns (bool) {
      return _setRate(rate_)
  }

  function beginPresale(uint daysFromStart) 
    external onlyWithdrawalAddress() returns (bool) {
      require(!_initialized, "Error: Presale already begun");
      _startTime = block.timestamp;
      _endTime = block.timestamp + (daysFromStart * 1 days);
      _initialized = true;
      emit PresaleStarted(_startTime, _endTime);
  }

  function extendPresale(uint extension) 
    external onlyWithdrawalAddress() returns (bool) {
      require(!_finalized, "Error: Presale has been finalized and cannot be extended");
      _endTime = block.timestamp + (extension * 1 days);
      emit PresaleExtended(_endTime);
      return true;
  }

  function finalizePresale() external onlyWithdrawalAddress() returns (bool) {
    require(!_finalized, "Error: Presale cannot be finalized twice");
    _finalized = true;
    emit PresaleFinalized(block.timestamp);
    return true;
  }

  function getRemainingDays() public returns (uint) {
    uint currentTimestamp = block.timestamp;
    
    if (_endTime > currentTimestamp)
      return _endTime - currentTimestamp;

    return 0; 
  }

  function buy(uint amount) external returns (bool) {
    require(block.timestamp >= _startTime, "Error: Presale hasn't begun yet");
    require(block.timestamp < _endTime, "Error: Presale has ended");
    (bool success, ) = _withdrawalWallet.call{ value: amount }("");
    require(success, "Error: Failed to send BNB to purchase XOXCASH");
    bool sold = _tradeToken.transferFrom(_withdrawalWallet, msg.sender, amount / _rate);
    require(sold, "Error: Failed to send XOXCASH");
    emit TokenSold(amount / _rate, msg.sender)
  }

  function setWithdrawalWallet(address withdrawalWallet_) 
    external onlyOwner() returns (bool) {
      _withdrawalWallet = withdrawalWallet_;
      return true;
  }
}