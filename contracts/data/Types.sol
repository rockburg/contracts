//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum Types {
	MUSICIAN,
	VENUE,
	STUDIO,
	BAND,
	SONG
}

enum Role {
	VOCALIST,
	LEAD_GUITAR,
	RHYTHM_GUITAR,
	BASS,
	DRUMS
}

struct Musician {
	string name;
	Role role;
	uint256 skillPoints;
	uint256 egoPoints;
	uint256 lookPoints;
	uint256 creativePoints;
}

struct Venue {
	string name;
	string location;
	uint256 visitorCap;
	uint256 dollarCost;
	uint256 cleanlinessPoints;
	uint256 reputationPoints;
}

struct Studio {
	string name;
	string location;
	uint256 dollarCost;
	uint256 leadTime;
	uint256 reputationPoints;
}

struct Band {
	string name;
	string bandType;
	uint256 fanCount;
	uint256 buzzPoints;
	uint256 vocalistId;
	uint256 leadGuitarId;
	uint256 rhythmGuitarId;
	uint256 bassId;
	uint256 drumsId;
}

struct Song {
	string name;
	string author;
	uint256 qualityPoints;
	uint256 streamCount;
	uint256 ratingPoints;
}
