 //SPDX-License-Identifier: UNLICENSED
 pragma solidity ^0.8.0;
 library Address {
    function isContract(address account) internal view returns(bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendvalue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Insufficient balance');
        (bool success, ) = recipient.call{value:amount}('');
        require(success, 'Unable to send,value, recipient may have reverted');
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) 
    internal returns(bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) 
    internal returns(bytes memory) {
        require(address(this).balance >= value, 'Insufficient balance for call');
        require(isContract(target), 'Call to non-contract');
        (bool success, bytes memory returndata) = target.call{value:value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage)
    internal view returns(bytes memory) {
        require(isContract(target), 'Static call to non-contract');
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) 
    internal returns(bytes memory) {
        require(isContract(target), 'Delegate call to non-contract');
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage)
    internal pure returns(bytes memory) {
        if(success) {
            return returndata;
        } else {
            if(returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
 }
 library Strings {
    bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

    function toString(uint256 value) internal pure returns(string memory) {
        if(value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while(temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while(value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns(string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for(uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, 'Hex length insufficient');
        return string(buffer);
    }
}
 contract ERC721 {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    string private _baseTokenURI;
    bytes4 private _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor () {}
    function _msgSender() internal view returns(address) {
        return msg.sender;
    }
    function _msgData() internal pure returns(bytes calldata) {
        return msg.data;
    }
    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function ownerOf(uint256 tokenId) public view returns(address) {
        address owner = _owners[tokenId];
        require(owner != address(0), 'Owner query for nonexistent token');
        return owner;
    }
    function balanceOf(address owner) public view returns(uint256) {
        require(owner != address(0), ' Balance query for the zero address');
        return _balances[owner];
    }
    function tokenURI(uint256 tokenId) public view returns(string memory) {
        require(_exists(tokenId), 'URI query for nonexistent token');
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }
    function _baseURI() internal view returns(string memory) {
        return _baseTokenURI;
    }
    function _exists(uint256 tokenId) internal view returns(bool) {
        return _owners[tokenId] != address(0);
    }
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, 'Approval to current owner');
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            'Approve caller is not the owner nor approved for it');
        _approve(to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    function getApproved(uint256 tokenId) public view returns(address) {
        require(_exists(tokenId), 'Approved query for nonexistent token');
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != _msgSender(), 'Approve to caller');
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return _operatorApprovals[owner][operator];
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        require(_exists(tokenId), 'Operator query for nonexistent token');
        address owner = ownerOf(tokenId);
        return(spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner,spender));
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), ' Transfer caller is not the owner not approved');
        _transfer(from, to, tokenId);
    }
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, 'Transfer of token that is not own');
        require(to != address(0), 'Transfer to the zero address');
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -=  1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), 'Transfer caller is not the owner nor approved');
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), 'Transfer to non ERC721Receiver implementer');
    }
    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private view returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data),
            'Transfer to non ERC721Receiver implementer');
    }
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), 'Mint to the zero address');
        require(!_exists(tokenId), 'Token already minted');
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
}