//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../data/Types.sol";

interface IMusicianRenderer {
    function constructTokenURI(Musician calldata musician, uint256 tokenId) external pure returns (string memory);
}
