pragma solidity ^0.4.11;


contract Purchase {
	//This is list of this contract's owner
	address sellerAddr;
	//This is list of this contract's buyer
	address buyerAddr;
	//This is map of this contract's buyer
	mapping (address => uint256) buyerMap;
	//This is the total amount of this contract
	uint256 totalAmount;
	//This is initialValue of this contract
	uint256 initialValue;
	//This is the status of this contract
	uint256 status;

	event PurchaseConfirmed(address _from, uint256 _amount);
	event ItemReceived(address _from);
	event Aborted(address _from);

	modifier onlyBuyer { 
		require(isBuyer(msg.sender)); 
		_; 
	}

	function isBuyer(address _addr) constant returns (bool) {
		return buyerMap[_addr] > 0;
	}

	modifier onlySeller { 
		require(isSeller(msg.sender)); 
		_; 
	}
	
	function isSeller(address _addr) constant returns (bool) {
		return sellerAddr == _addr;
	}
	
	function Purchase() payable {
		sellerAddr = msg.sender;
		totalAmount = msg.value;
		initialValue = totalAmount / 2;
		status = 0;
	}

	function seller() constant returns (address) {
		return sellerAddr;
	}

	function buyer() constant returns (address) {
		return buyerAddr;
	}

	function value() constant returns (uint256) {
		return initialValue;
	}

	function state() constant returns (uint256) {
		return status;
	}

	function confirmPurchase() payable {
		require(msg.value == totalAmount);
		require(status == 0);
		totalAmount += msg.value;
		buyerAddr = msg.sender;
		buyerMap[msg.sender] = msg.value;
		status = 1;
		PurchaseConfirmed(msg.sender, msg.value);
	}

	function confirmReceived() onlyBuyer {
		require(status == 1);
		sellerAddr.transfer(totalAmount - initialValue);
		buyerAddr.transfer(initialValue);
		status = 2;
		ItemReceived(msg.sender);
	}

	function abort() onlySeller {
		require(status == 0);
		sellerAddr.transfer(totalAmount);
		status = 2;
		Aborted(msg.sender);
	}
}
