//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RockburgNFT contract by m1guelpf.eth

import "./data/Types.sol";
import "base64-sol/base64.sol";
import "./interfaces/IVenueRenderer.sol";
import "./interfaces/IStudioRenderer.sol";
import "./interfaces/IMusicianRenderer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RockburgNFT is Ownable, ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private randomnessNonce;

    address internal _musicianRenderer;
    address internal _venueRenderer;
    address internal _studioRenderer;

    mapping(uint256 => Types) private _tokenTypes;
    mapping(uint256 => Musician) private _musicians;
    mapping(uint256 => Venue) private _venues;
    mapping(uint256 => Studio) private _studios;
    mapping(uint256 => Band) private _bands;
    mapping(uint256 => Song) private _songs;

    constructor(address musicianRenderer, address venueRenderer, address studioRenderer) ERC721("Rockburg", "RCKBRG") {
        _musicianRenderer = musicianRenderer;
        _venueRenderer = venueRenderer;
        _studioRenderer = studioRenderer;
    }

    /**
     * @dev Creates a new artist token with pseudo-randomized stats and returns its identifier.
     * For simplicity, we do not check wether the caller implements ERC721Receiver.
    */
    function mintArtist(string calldata name, string calldata role) public returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        _tokenTypes[tokenId] = Types.MUSICIAN;
        Musician storage musician = _musicians[tokenId];
        musician.name = name;
        musician.role = role;
        musician.skillPoints = randNum(abi.encodePacked(name, role)) % 100;
        musician.egoPoints = randNum(abi.encodePacked(name, role)) % 100;
        musician.lookPoints = randNum(abi.encodePacked(name, role)) % 100;
        musician.creativePoints = randNum(abi.encodePacked(name, role)) % 100;

        _mint(_msgSender(), tokenId);

        return tokenId;
    }

    /**
     * @dev Creates a new venue token with pseudo-randomized stats and returns its identifier.
     * For simplicity, we do not check wether the caller implements ERC721Receiver.
    */
    function mintVenue(string calldata name, string calldata location) public returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        _tokenTypes[tokenId] = Types.VENUE;
        Venue storage venue = _venues[tokenId];
        venue.name = name;
        venue.location = location;
        venue.visitorCap = randNum(abi.encodePacked(name, location)) % 100;
        venue.dollarCost = randNum(abi.encodePacked(name, location)) % 100;
        venue.cleanlinessPoints = randNum(abi.encodePacked(name, location)) % 100;
        venue.reputationPoints = randNum(abi.encodePacked(name, location)) % 100;

        _mint(_msgSender(), tokenId);

        return tokenId;
    }

    /**
     * @dev Creates a new studio token with pseudo-randomized stats and returns its identifier.
     * For simplicity, we do not check wether the caller implements ERC721Receiver.
    */
    function mintStudio(string calldata name, string calldata location) public returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        _tokenTypes[tokenId] = Types.STUDIO;
        Studio storage studio = _studios[tokenId];
        studio.name = name;
        studio.location = location;
        studio.dollarCost = randNum(abi.encodePacked(name, location)) % 50;
        studio.leadTime = randNum(abi.encodePacked(name, location)) % 12;
        studio.reputationPoints = randNum(abi.encodePacked(name, location)) % 100;

        _mint(_msgSender(), tokenId);

        return tokenId;
    }

    function getType(uint256 tokenId) public view virtual returns (Types) {
        return _tokenTypes[tokenId];
    }

    function getMusician(uint256 tokenId) public view virtual returns (Musician memory) {
        require(_exists(tokenId), "token does not exist");
        require(_tokenTypes[tokenId] == Types.MUSICIAN, "token is not a musician");

        return _musicians[tokenId];
    }

    function getVenue(uint256 tokenId) public view virtual returns (Venue memory) {
        require(_exists(tokenId), "token does not exist");
        require(_tokenTypes[tokenId] == Types.VENUE, "token is not a venue");

        return _venues[tokenId];
    }

    function getStudio(uint256 tokenId) public view virtual returns (Studio memory) {
        require(_exists(tokenId), "token does not exist");
        require(_tokenTypes[tokenId] == Types.STUDIO, "token is not a studio");

        return _studios[tokenId];
    }

    function getBand(uint256 tokenId) public view virtual returns (Band memory) {
        require(_exists(tokenId), "token does not exist");
        require(_tokenTypes[tokenId] == Types.BAND, "token is not a studio");

        return _bands[tokenId];
    }

    function getSong(uint256 tokenId) public view virtual returns (Song memory) {
        require(_exists(tokenId), "token does not exist");
        require(_tokenTypes[tokenId] == Types.SONG, "token is not a song");

        return _songs[tokenId];
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "token does not exist");

        Types tokenType = _tokenTypes[tokenId];

        if (tokenType == Types.MUSICIAN) {
            return IMusicianRenderer(_musicianRenderer).constructTokenURI(_musicians[tokenId], tokenId);
        }
        if (tokenType == Types.VENUE) {
            return IVenueRenderer(_venueRenderer).constructTokenURI(_venues[tokenId], tokenId);
        }
        if (tokenType == Types.STUDIO) {
            return IStudioRenderer(_studioRenderer).constructTokenURI(_studios[tokenId], tokenId);
        }

        return "TBD";
    }

    /**
     * @dev Returns a pseudo-random `uint256`, based off a provided seed, the sender, block number, block difficulty, and an internal nonce.
    */
    function randNum(bytes memory seed) internal returns (uint256) {
        randomnessNonce.increment();

        return uint256(keccak256(abi.encodePacked(seed, msg.sender, block.number, block.difficulty, randomnessNonce.current())));
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
