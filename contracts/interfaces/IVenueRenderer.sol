//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../data/Types.sol";

interface IVenueRenderer {
    function constructTokenURI(Venue calldata venue, uint256 tokenId) external pure returns (string memory);
}
