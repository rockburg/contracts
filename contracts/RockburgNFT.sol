//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RockburgNFT contract by m1guelpf.eth

import './data/Types.sol';
import 'base64-sol/base64.sol';
import './interfaces/IVenueRenderer.sol';
import './interfaces/IStudioRenderer.sol';
import './interfaces/IMusicianRenderer.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

import 'hardhat/console.sol';

contract RockburgNFT is Ownable, ERC721, ERC721Enumerable, ERC721Holder {
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

	constructor(
		address musicianRenderer,
		address venueRenderer,
		address studioRenderer
	) ERC721('Rockburg', 'RCKBRG') {
		_musicianRenderer = musicianRenderer;
		_venueRenderer = venueRenderer;
		_studioRenderer = studioRenderer;
	}

	/**
	 * @dev Creates a new band token with pseudo-randomized stats and returns its identifier.
	 * For simplicity, we do not check wether the caller implements ERC721Receiver.
	 */
	function mintBand(string calldata name, string calldata bandType) internal returns (uint256) {
		_tokenIds.increment();

		uint256 tokenId = _tokenIds.current();

		_tokenTypes[tokenId] = Types.BAND;
		Band storage band = _bands[tokenId];

		band.name = name;
		band.bandType = bandType;
		band.fanCount = randNum(abi.encodePacked(name, bandType)) % 100;
		band.buzzPoints = randNum(abi.encodePacked(name, bandType)) % 100;

		_mint(_msgSender(), tokenId);

		return tokenId;
	}

	/**
	 * @dev Creates a new artist token with pseudo-randomized stats and returns its identifier.
	 * For simplicity, we do not check wether the caller implements ERC721Receiver.
	 */
	function mintArtist(string calldata name, Role role) public returns (uint256) {
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
		require(_exists(tokenId), 'token does not exist');
		require(_tokenTypes[tokenId] == Types.MUSICIAN, 'token is not a musician');

		return _musicians[tokenId];
	}

	function getVenue(uint256 tokenId) public view virtual returns (Venue memory) {
		require(_exists(tokenId), 'token does not exist');
		require(_tokenTypes[tokenId] == Types.VENUE, 'token is not a venue');

		return _venues[tokenId];
	}

	function getStudio(uint256 tokenId) public view virtual returns (Studio memory) {
		require(_exists(tokenId), 'token does not exist');
		require(_tokenTypes[tokenId] == Types.STUDIO, 'token is not a studio');

		return _studios[tokenId];
	}

	function getBand(uint256 tokenId) public view virtual returns (Band memory) {
		require(_exists(tokenId), 'token does not exist');
		require(_tokenTypes[tokenId] == Types.BAND, 'token is not a band');

		return _bands[tokenId];
	}

	function getSong(uint256 tokenId) public view virtual returns (Song memory) {
		require(_exists(tokenId), 'token does not exist');
		require(_tokenTypes[tokenId] == Types.SONG, 'token is not a song');

		return _songs[tokenId];
	}

	function checkArtistRole(uint256 tokenId, Role expectedRole) internal view returns (bool) {
		return _musicians[tokenId].role == expectedRole;
	}

	/**
	 * @dev Form a band
	 */
	function formBand(
		string calldata name,
		string calldata bandType,
		uint256 vocalistId,
		uint256 leadGuitarId,
		uint256 rhythmGuitarId,
		uint256 bassId,
		uint256 drumsId
	) public returns (Band memory) {
		// Check the type of the token
		require(_tokenTypes[vocalistId] == Types.MUSICIAN, 'vocalistId is not an artist');
		require(_tokenTypes[leadGuitarId] == Types.MUSICIAN, 'leadGuitarId is not an artist');
		require(_tokenTypes[rhythmGuitarId] == Types.MUSICIAN, 'rhythmGuitarId is not an artist');
		require(_tokenTypes[bassId] == Types.MUSICIAN, 'bassId is not an artist');
		require(_tokenTypes[drumsId] == Types.MUSICIAN, 'drumsId is not an artist');

		require(checkArtistRole(vocalistId, Role.VOCALIST), 'vocalistId is not a Vocalist');
		require(checkArtistRole(leadGuitarId, Role.LEAD_GUITAR), 'leadGuitarId is not a Lead Guitar');
		require(checkArtistRole(rhythmGuitarId, Role.RHYTHM_GUITAR), 'rhythmGuitarId is not a Rhythm Guitar');
		require(checkArtistRole(bassId, Role.BASS), 'bassId is not a Bass');
		require(checkArtistRole(drumsId, Role.DRUMS), 'drumsId is not a Drums');

		// transfer all those artist to the contract itself, this will also automatically
		// check that the send owns the token
		safeTransferFrom(msg.sender, address(this), vocalistId);
		safeTransferFrom(msg.sender, address(this), leadGuitarId);
		safeTransferFrom(msg.sender, address(this), rhythmGuitarId);
		safeTransferFrom(msg.sender, address(this), bassId);
		safeTransferFrom(msg.sender, address(this), drumsId);

		uint256 bandId = mintBand(name, bandType);

		// bind artist to band
		Band storage _band = _bands[bandId];
		_band.vocalistId = vocalistId;
		_band.leadGuitarId = leadGuitarId;
		_band.rhythmGuitarId = rhythmGuitarId;
		_band.bassId = bassId;
		_band.drumsId = drumsId;

		return _band;
	}

	function disbandBand(uint256 bandId) public {
		require(_isApprovedOrOwner(msg.sender, bandId), "You don't own the band");
		require(_tokenTypes[bandId] == Types.BAND, 'token is not a band');

		// bind artist to band
		Band storage _band = _bands[bandId];

		// transfer all those artist to the contract itself, this will also automatically
		// check that the send owns the token

		_transfer(address(this), msg.sender, _band.vocalistId);
		_transfer(address(this), msg.sender, _band.leadGuitarId);
		_transfer(address(this), msg.sender, _band.rhythmGuitarId);
		_transfer(address(this), msg.sender, _band.bassId);
		_transfer(address(this), msg.sender, _band.drumsId);

		// Should we just reset the band and transfer it back to us or burn it?

		// Safe transfer:  option 1
		// _band.vocalistId = 0;
		// _band.leadGuitarId = 0;
		// _band.rhythmGuitarId = 0;
		// _band.bassId = 0;
		// _band.drumsId = 0;
		// safeTransferFrom(msg.sender, address(this), bandId);

		// Burn it: option 2
		_burn(bandId);
		delete _bands[bandId];
	}

	/**
	 * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
	 */
	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
		require(_exists(tokenId), 'token does not exist');

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

		return 'TBD';
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
	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal virtual override(ERC721, ERC721Enumerable) {
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
