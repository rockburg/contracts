//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../data/Types.sol";
import "../utils/Strings.sol";
import "base64-sol/base64.sol";
import "../interfaces/IStudioRenderer.sol";

contract StudioRenderer is IStudioRenderer, Strings {
    function constructTokenURI(Studio calldata studio, uint256 tokenId) external pure override returns (string memory) {
        string[12] memory parts;
        // solhint-disable-next-line quotes
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1{fill:#b120ed;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style>';

        // solhint-disable-next-line quotes
        parts[1] = '</defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">';
        parts[2] = studio.name;

        // solhint-disable-next-line quotes
        parts[3] = '</text><text class="cls-4" transform="translate(38.89 131.34)">';
        parts[4] = studio.location;

        // solhint-disable-next-line quotes
        parts[5] = '</text><text class="cls-5" transform="translate(38.4 334.04)">Cost</text><text class="cls-6" transform="translate(270.54 334.04)">&sect;';
        parts[6] = Strings.uintToString(studio.dollarCost);

        // solhint-disable-next-line quotes
        parts[7] = ',000</text><text class="cls-5" transform="translate(38.4 393.85)">Lead Time</text><text class="cls-6" transform="translate(347.24 393.85)">';
        parts[8] = Strings.uintToString(studio.leadTime);

        // solhint-disable-next-line quotes
        parts[9] = ' mo</text><text class="cls-5" transform="translate(38.4 453.67)">Reputation</text><text class="cls-6" transform="translate(398.37 453.67)">';
        parts[10] = Strings.uintToString(studio.reputationPoints);

        // solhint-disable-next-line quotes
        parts[11] = '</text><rect class="cls-1" x="6.1" y="9" width="106.78" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Studio</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11]));

        // solhint-disable-next-line quotes
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Studio #', Strings.uintToString(tokenId), '", "description": "Rockburg is a WIP card game on the blockchain.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }
}
