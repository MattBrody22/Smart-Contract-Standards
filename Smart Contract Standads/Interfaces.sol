// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}
interface IERC1155Receiver is IERC165 {
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns(bytes4);
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns(bytes4);
} 
interface ERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] id, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns(uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns(uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address acount, address operator) external view returns(bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}
interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns(string memory);
}
interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERCMetadata is IERC20 {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
}
interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owneer) external view returns(uint256);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns(uint256 balance);
    function ownerOf(uint256 tokenId) external view returns(address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns(address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns(bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function tokenURI(uint256 tokenId) external view returns(string memory);
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256 tokenId);
    function tokenByIndex(uint index) external voew returns(uint256);
}
interface IERC777 {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function ganularity() external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function send(address recipient, uint256 amount, bytes calldata data) external;
    function burn(uint256 amount, bytes calldata data) external;
    function isOperatorFor(address operator, address tokenHolder) external view returns(bool);
    function autherizeOperator(address operator) external;
    function revokeOperator(address operator) external;
    function defaultOperators() external view returns(address[] memory);
    function operatorSend(address sender, address recipient, uint256 amount, bytes calldata data, bytes calldata operatorData) external;
    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external;
    event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes data, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    event AutherizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokeOperator(address indexed operator, address indexed tokenHolder);
}
interface IERC777Recipient {
    function tokensReceived(address operator, address from, address to, uint256 amount, bytes calldata userData, bytes calldata operatorData) external;
}
interface IERC777Sendr {
    function tokenToSend(address operator, address from, address to, uint256 amount, bytes calldata userData, bytes calldata operatorData) external;
    
}