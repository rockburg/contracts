//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RockburgNFT contract by m1guelpf.eth

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RockburgNFT is Ownable, ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Musician {
        string name;
        string role;
        uint256 skillPoints;
        uint256 egoPoints;
        uint256 lookPoints;
        uint256 creativePoints;
    }

    mapping(uint256 => Musician) public musicians;

    // solhint-disable-next-line no-empty-blocks
    constructor() ERC721("Rockburg", "RCKBRG") {}

    /**
     * @dev Creates a new token with the specified metadata and returns its identifier.
     * For simplicity, we do not check wether the caller implements ERC721Receiver.
    */
    function mintWithStats(string calldata name, string calldata role, uint256 skillPoints, uint256 egoPoints, uint256 lookPoints, uint256 creativePoints) public returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        Musician storage musician = musicians[tokenId];
        musician.name = name;
        musician.role = role;
        musician.skillPoints = skillPoints;
        musician.egoPoints = egoPoints;
        musician.lookPoints = lookPoints;
        musician.creativePoints = creativePoints;

        _mint(_msgSender(), tokenId);

        return tokenId;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "token does not exist");

        Musician memory musician = musicians[tokenId];

        string[14] memory parts;
        // solhint-disable-next-line quotes
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1,.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style>';

        // solhint-disable-next-line quotes
        parts[1] = '</defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">';
        parts[2] = musician.name;

        // solhint-disable-next-line quotes
        parts[3] = '</text><text class="cls-4" transform="translate(38.89 131.34)">';
        parts[4] = musician.role;

        // solhint-disable-next-line quotes
        parts[5] = '</text><text class="cls-5" transform="translate(38.4 274.23)">Skill</text><text class="cls-6" transform="translate(398.37 274.23)">';
        parts[6] = toString(musician.skillPoints);

        // solhint-disable-next-line quotes
        parts[7] = '</text><text class="cls-5" transform="translate(38.4 334.04)">Ego</text><text class="cls-6" transform="translate(398.37 334.04)">';
        parts[8] = toString(musician.egoPoints);

        // solhint-disable-next-line quotes
        parts[9] = '</text><text class="cls-5" transform="translate(38.4 393.85)">Looks</text><text class="cls-6" transform="translate(398.37 393.85)">';
        parts[10] = toString(musician.lookPoints);

        // solhint-disable-next-line quotes
        parts[11] = '</text><text class="cls-5" transform="translate(38.4 453.67)">Creativity</text><text class="cls-6" transform="translate(398.37 453.67)">';
        parts[12] = toString(musician.creativePoints);

        // solhint-disable-next-line quotes
        parts[13] = '</text><rect class="cls-1" x="6.1" y="9" width="138.93" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Musician</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13]));

        // solhint-disable-next-line quotes
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Musician #', toString(tokenId), '", "description": "Rockburg is a WIP card game on the blockchain.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
    */
    function toString(uint256 v) internal pure returns (string memory) {
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

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning.
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
