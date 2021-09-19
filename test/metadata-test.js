const { expect } = require('chai')
const { ethers } = require('hardhat')

const renderers = ['Musician', 'Venue', 'Studio']

describe('RockburgNFT', function () {
	let contract

	beforeEach(async () => {
		const rendererAddresses = await Promise.all(
			renderers.map(async type => {
				const Renderer = await ethers.getContractFactory(`${type}Renderer`)
				const renderer = await Renderer.deploy()
				await renderer.deployed()

				return renderer.address
			})
		)

		const RockburgNFT = await ethers.getContractFactory('RockburgNFT')
		contract = await RockburgNFT.deploy(...rendererAddresses)
		await contract.deployed()
	})

	it('correctly generates metadata for a musician', async function () {
		const mintTx = await contract.mintArtist('Shpigford', 'Coder')

		// wait until the transaction is mined
		await mintTx.wait()

		const [tokenURI, artistStats] = await Promise.all([contract.tokenURI(1), contract.getMusician(1)])
		const metadata = JSON.parse(base64Decode(strAfter(tokenURI, 'data:application/json;base64,')))
		const generatedSVG = base64Decode(strAfter(metadata.image, 'data:image/svg+xml;base64,'))

		expect(metadata.name).to.equal('Musician #1')
		expect(metadata.description).to.equal('Rockburg is a WIP card game on the blockchain.')
		expect(generatedSVG).to.equal(generateMusicianSVG(...artistStats))
	})

	it('correctly generates metadata for a venue', async function () {
		const mintTx = await contract.mintVenue('Rockburg', 'Metaverse')

		// wait until the transaction is mined
		await mintTx.wait()

		const [tokenURI, venueStats] = await Promise.all([contract.tokenURI(1), contract.getVenue(1)])
		const metadata = JSON.parse(base64Decode(strAfter(tokenURI, 'data:application/json;base64,')))
		const generatedSVG = base64Decode(strAfter(metadata.image, 'data:image/svg+xml;base64,'))

		expect(metadata.name).to.equal('Venue #1')
		expect(metadata.description).to.equal('Rockburg is a WIP card game on the blockchain.')
		expect(generatedSVG).to.equal(generateVenueSVG(...venueStats))
	})

	it('correctly generates metadata for a studio', async function () {
		const mintTx = await contract.mintStudio('Rockburg', 'Metaverse')

		// wait until the transaction is mined
		await mintTx.wait()

		const [tokenURI, studioStats] = await Promise.all([contract.tokenURI(1), contract.getStudio(1)])
		const metadata = JSON.parse(base64Decode(strAfter(tokenURI, 'data:application/json;base64,')))
		const generatedSVG = base64Decode(strAfter(metadata.image, 'data:image/svg+xml;base64,'))

		expect(metadata.name).to.equal('Studio #1')
		expect(metadata.description).to.equal('Rockburg is a WIP card game on the blockchain.')
		expect(generatedSVG).to.equal(generateStudioSVG(...studioStats))
	})
})

const strAfter = (haysack, needle) => haysack.split(needle).pop()
const base64Decode = string => Buffer.from(string, 'base64').toString('utf-8')
const generateMusicianSVG = (name, role, skillPoints, egoPoints, lookPoints, creativePoints) =>
	`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1,.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style></defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">${name}</text><text class="cls-4" transform="translate(38.89 131.34)">${role}</text><text class="cls-5" transform="translate(38.4 274.23)">Skill</text><text class="cls-6" transform="translate(398.37 274.23)">${skillPoints}</text><text class="cls-5" transform="translate(38.4 334.04)">Ego</text><text class="cls-6" transform="translate(398.37 334.04)">${egoPoints}</text><text class="cls-5" transform="translate(38.4 393.85)">Looks</text><text class="cls-6" transform="translate(398.37 393.85)">${lookPoints}</text><text class="cls-5" transform="translate(38.4 453.67)">Creativity</text><text class="cls-6" transform="translate(398.37 453.67)">${creativePoints}</text><rect class="cls-1" x="6.1" y="9" width="138.93" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Musician</text></svg>`
const generateVenueSVG = (name, location, visitorCap, dollarCost, cleanlinessPoints, reputationPoints) =>
	`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1{fill:#1d59ef;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style></defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">${name}</text><text class="cls-4" transform="translate(38.89 131.34)">${location}</text><text class="cls-5" transform="translate(38.4 274.23)">Cap</text><text class="cls-6" transform="translate(321.67 274.23)">${visitorCap}</text><text class="cls-5" transform="translate(38.4 334.04)">Cost</text><text class="cls-6" transform="translate(372.8 334.04)">&#xa7;${dollarCost}</text><text class="cls-5" transform="translate(38.4 393.85)">Cleanliness</text><text class="cls-6" transform="translate(398.37 393.85)">${cleanlinessPoints}</text><text class="cls-5" transform="translate(38.4 453.67)">Reputation</text><text class="cls-6" transform="translate(398.37 453.67)">${reputationPoints}</text><rect class="cls-1" x="6.1" y="9" width="97.19" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Venue</text></svg>`
const generateStudioSVG = (name, location, dollarCost, leadTime, reputationPoints) =>
	`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><defs><style>@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&amp;display=swap");.cls-1{fill:#b120ed;}.cls-2,.cls-7{fill:#fff;}.cls-3{font-size:49.11px;}.cls-3,.cls-4,.cls-5,.cls-6{fill:#181818;}.cls-3,.cls-6,.cls-7{font-weight:700;}.cls-4,.cls-7{font-size:19.22px;}.cls-3,.cls-6,.cls-7,.cls-4,.cls-5{font-family:Space Mono;}.cls-5,.cls-6{font-size:41.77px;}</style></defs><rect class="cls-1" width="500" height="500"/><rect class="cls-2" x="10" y="10" width="480" height="480"/><text class="cls-3" transform="translate(36.43 104.21)">${name}</text><text class="cls-4" transform="translate(38.89 131.34)">${location}</text><text class="cls-5" transform="translate(38.4 334.04)">Cost</text><text class="cls-6" transform="translate(270.54 334.04)">&#xa7;${dollarCost},000</text><text class="cls-5" transform="translate(38.4 393.85)">Lead Time</text><text class="cls-6" transform="translate(347.24 393.85)">${leadTime} mo</text><text class="cls-5" transform="translate(38.4 453.67)">Reputation</text><text class="cls-6" transform="translate(398.37 453.67)">${reputationPoints}</text><rect class="cls-1" x="6.1" y="9" width="106.78" height="36.83"/><text class="cls-7" transform="translate(25.89 30.41)">Studio</text></svg>`
