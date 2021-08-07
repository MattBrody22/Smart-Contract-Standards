// SPDX-License-Identifier: UNLICENDED
pragma solidity ^0.8.0;
library Buffer {
    struct buffer{bytes buf; uint capacity;}
    function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {
        if(capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(32, add(ptr, capacity)))
        }
        return buf;
    }
    function fromBytes(bytes memory b) internal pure returns(buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }
    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }
    function max(uint a, uint b) private pure returns(uint) {
        if(a > b) {
            return a;
        }
        return b;
    }
    function truncate(buffer memory buf) internal pure returns(buffer memory) {
        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }
    function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns(buffer memory) {
        require(len <= data.length);
        if(off + len > buf.capacity) {
            resize(buf, max(buf.capacity, len + off) * 2);
        }
        uint dest;
        uint src;
        assembly {
            let bufptr := mload(buf)
            let buflen := mload(bufptr)
            dest := add(add(bufptr, 32), off)
            if gt(add(len, off), buflen) {
                mstore(bufptr, add(len, off))
            }
            src := add(data, 32)
        }
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
        return buf;
    }
    function append(buffer memory buf, bytes memory data, uint len) internal pure returns(buffer memory) {
        return write(buf, buf.buf.length, data, len);
    }
    function append(buffer memory buf, bytes memory data) internal pure returns(buffer memory) {
        return write(buf, buf.buf.length, data, data.length);
    }
    function writeUint8(buffer memory buf, uint off, uint8 data) internal pure returns(buffer memory) {
        if(off >= buf.capacity) {
            resize(buf, buf.capacity * 2);
        }
        assembly {
            let bufptr := mload(buf)
            let buflen := mload(bufptr)
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            if eq(off, buflen) {
                mstore(bufptr, add(buflen, 1))
            }
        }
        return buf;
    }
    function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {
        return writeUint8(buf, buf.buf.length, data);
    }
    function write(buffer memory buf, uint off, bytes32 data, uint len) private pure returns(buffer memory) {
        if(len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }
        uint mask = 256 ** len - 1;
        data = data >> (8 * (32 - len));
        assembly {
            let bufptr := mload(buf)
            let dest := add(add(bufptr, off), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            if gt(add(off, len), mload(bufptr)) {
                mstore(bufptr, add(off, len))
            }
        }
        return buf;
    }
    function writeBytes20(buffer memory buf, uint off, bytes20 data) internal pure returns(buffer memory) {
        return write(buf, off, bytes32(data), 20);
    }
    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns(buffer memory) {
        return write(buf, buf.buf.length, bytes32(data), 20);
    }
    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns(buffer memory) {
        return write(buf, buf.buf.length, data, 32);
    }
    function writeInt(buffer memory buf, uint off, uint data, uint len) private pure returns(buffer memory) {
        if(len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }
        uint mask = 256 ** len -1;
        assembly {
            let bufptr := mload(buf)
            let dest := add(add(bufptr, off), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            if gt(add(off, len), mload(bufptr)) {
                mstore(bufptr, add(off, len))
            }
        }
        return buf;
    }
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        return writeInt(buf, buf.buf.length, data, len);
    }
}
library CBORChainlink {
    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;
    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
        if(value <= 23) {
          buf.appendUint8(uint8((major << 5) | value));
        } else if(value <= 0xFF) {
          buf.appendUint8(uint8((major << 5) | 24));
          buf.appendInt(value, 1);
        } else if(value <= 0xFFFF) {
          buf.appendUint8(uint8((major << 5) | 25));
          buf.appendInt(value, 2);
        } else if(value <= 0xFFFFFFFF) {
          buf.appendUint8(uint8((major << 5) | 26));
          buf.appendInt(value, 4);  
        } else if(value <= 0xFFFFFFFFFFFFFFFF) {
          buf.appendUint8(uint8((major << 5) | 27));
          buf.appendInt(value, 8);  
        }
    }
    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {
        buf.appendUint8(uint8((major << 5) | 31));
    }
    function encodeInt(Buffer.buffer memory buf, uint value) internal pure {
        encodeType(buf, MAJOR_TYPE_INT, value);
    }
    function encodeInt(Buffer.buffer memory buf, int value) internal pure {
        if(value < -0x10000000000000000) {
            encodeSignedBigNum(buf, value);
        } else if(value >= 0xFFFFFFFFFFFFFFFF) {
            encodeBigNum(buf, value);
        } else if(value >= 0) {
            encodeType(buf, MAJOR_TYPE_INT, uint(value));
        }
    }
    function encodeBytes(Buffer.buffer memory buf, bytes memory value) internal pure {
        encodeType(buf, MAJOR_TYPE_BYTES, value.length);
        buf.append(value);
    }
    function encodeBigNum(Buffer.buffer memory buf, int value) internal pure {
        buf.appendUint8(uint8((MAJOR_TYPE_TAG) | TAG_TYPE_BIGNUM));
        encodeBytes(buf, abi.encode(uint(value)));
    }
    function encodeSignedBigNum(Buffer.buffer memory buf, int input) internal pure {
        buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM));
        encodeBytes(buf, abi.encode(uint(-1 - input)));
    }
    function enocodeString(Buffer.buffer memory buf, string memory value) internal pure {
        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
        buf.append(bytes(value));
    }
    function startArray(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }
    function startMap(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }
    function endSequence(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }
}
library Chainlink {
    using CBORChainlink for Buffer.buffer;

    uint256 internal constant defaultBufferSize = 256;

    struct Request{bytes32 id; address callbackAddress;
    bytes4 callbackFunctonId; uint256 nonce; Buffer.buffer buf;}
}
contract SmartContracts {

}























