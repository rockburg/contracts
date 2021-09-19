//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
    */
    function uintToString(uint256 v) internal pure returns (string memory) {
        // Inspired by Probable's implementation - MIT licence
        // https://github.com/provable-things/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (v == 0) {
            return "0";
        }

        uint256 digits = countDigits(v);

        bytes memory buffer = new bytes(digits);

        while (v != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(v % 10)));
            v /= 10;
        }

        return string(buffer);
    }

    /**
     * @dev Calculate the number of digits on a `uint256`.
    */
    function countDigits(uint256 v) internal pure returns (uint256) {
        // Idea by proto.eth, not audited, from Twitter <https://twitter.com/protolambda/status/1433143248529367043>.
        // in assembly without overflow checks on the count value is probably faster
        uint256 count = 1;
        if (v >= 1000000000000000000000000000000000000000) { // 39 zeroes
            v /= 1000000000000000000000000000000000000000;
            count += 39;
        }
        if (v >= 100000000000000000000) { // 20 zeroes
            v /= 100000000000000000000;
            count += 20;
        }
        if (v >= 10000000000) { // 10 zeroes
            v /= 10000000000;
            count += 10;
        }
        if (v >= 100000) { // 5 zeroes
            v /= 100000;
            count += 5;
        }
        if (v >= 1000) { // 3 zeroes
            v /= 1000;
            count += 3;
        }
        if (v >= 100) { // 2 zeroes
            v /= 100;
            count += 2;
        }
        if (v >= 10) { // 1 zeroes
            v /= 10;
            count += 1;
        }
        return count;
    }
}
