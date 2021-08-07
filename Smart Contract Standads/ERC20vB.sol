
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
contract ERC20vB {
    address private _owner;
    string private _name; 
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;


    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor () {}
    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function _msgSender() internal view returns(address) {
        return msg.sender;
    }
    function _msgData() internal pure returns(bytes calldata) {
        return msg.data;
    }
    function ownerOf() public view returns(address) {
        return _msgSender();
    }
    function decimals() public view returns(uint8) {
        return _decimals;
    }
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns(uint256) {
        return _balances[account];
    }
    function approve(address spender, uint256 amount) public returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'Approve from the zero address');
        require(spender != address(0), 'Approve to the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function allowance(address owner, address spender) public view returns(uint256) {
        return _allowances[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, 'Decreased allowance below zero');
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal {}
    function transfer(address recipient, uint256 amount) public returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'Transfer from the zero address');
        require(recipient != address(0), 'Transfer to the zero address');
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, 'Transfer amount exceeds balance');
        _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns(bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, 'Transfer amount exceeds allowance');
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'Mint to zero address');
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'Burn from the zero address');
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
}