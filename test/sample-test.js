const fs = require('fs')
const path = require('path')
const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('RockburgNFT', function () {
	it('correctly generates SVG from metadata', async function () {
		const RockburgNFT = await ethers.getContractFactory('RockburgNFT')
		const contract = await RockburgNFT.deploy()
		await contract.deployed()

		const mintTx = await contract.mintArtist('Shpigford', 'Coder')

		// wait until the transaction is mined
		await mintTx.wait()

		const [tokenURI, artistStats] = await Promise.all([contract.tokenURI(1), contract.getMusician(1)])
		const metadata = JSON.parse(base64Decode(strAfter(tokenURI, 'data:application/json;base64,')))
		const generatedSVG = base64Decode(strAfter(metadata.image, 'data:image/svg+xml;base64,'))

		expect(metadata.name).to.equal('Musician #1')
		expect(metadata.description).to.equal('Rockburg is a WIP card game on the blockchain.')
		expect(generatedSVG).to.equal(generateMockSVG(...artistStats))
	})
})

const strAfter = (haysack, needle) => haysack.split(needle).pop()
const base64Decode = string => Buffer.from(string, 'base64').toString('utf-8')
const generateMockSVG = (name, role, skillPoints, egoPoints, lookPoints, creativePoints) =>
	`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1,.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style></defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">${name}</text><text class="cls-4" transform="translate(38.89 131.34)">${role}</text><text class="cls-5" transform="translate(38.4 274.23)">Skill</text><text class="cls-6" transform="translate(398.37 274.23)">${skillPoints}</text><text class="cls-5" transform="translate(38.4 334.04)">Ego</text><text class="cls-6" transform="translate(398.37 334.04)">${egoPoints}</text><text class="cls-5" transform="translate(38.4 393.85)">Looks</text><text class="cls-6" transform="translate(398.37 393.85)">${lookPoints}</text><text class="cls-5" transform="translate(38.4 453.67)">Creativity</text><text class="cls-6" transform="translate(398.37 453.67)">${creativePoints}</text><rect class="cls-1" x="6.1" y="9" width="138.93" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Musician</text></svg>`
