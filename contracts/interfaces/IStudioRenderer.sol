//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../data/Types.sol";

interface IStudioRenderer {
    function constructTokenURI(Studio calldata studio, uint256 tokenId) external pure returns (string memory);
}
