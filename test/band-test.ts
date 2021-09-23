import { Contract } from '@ethersproject/contracts'

import { ethers, waffle } from 'hardhat'
import chai from 'chai'
const { expect } = chai
const { deployContract } = waffle

const renderers = ['Musician', 'Venue', 'Studio']
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import RockburgNFTArtifact from '../artifacts/contracts/RockburgNFT.sol/RockburgNFT.json'
import { RockburgNFT } from '../typechain/RockburgNFT'

describe('Band test', function () {
	let owner: SignerWithAddress
	let addr1: SignerWithAddress
	let addrs: SignerWithAddress[]

	let contract: RockburgNFT

	beforeEach(async () => {
		;[owner, addr1, ...addrs] = await ethers.getSigners()
		const rendererAddresses = await Promise.all(
			renderers.map(async type => {
				const Renderer = await ethers.getContractFactory(`${type}Renderer`)
				const renderer = await Renderer.deploy()
				await renderer.deployed()

				return renderer.address
			})
		)

		contract = (await deployContract(owner, RockburgNFTArtifact, rendererAddresses)) as RockburgNFT
	})

	describe('Test formBand function', () => {
		it('formBand success', async function () {
			await contract.connect(addr1).mintArtist('Vocalist 1', 0) // VOCALIST
			await contract.connect(addr1).mintArtist('Lead Guitar 1', 1) // LEAD_GUITAR
			await contract.connect(addr1).mintArtist('Rhythm Guitar 1', 2) // RHYTHM_GUITAR
			await contract.connect(addr1).mintArtist('Bass 1', 3) // BASS
			await contract.connect(addr1).mintArtist('Drums 1', 4) // DRUMS

			// Artists owned by the user
			expect(await contract.ownerOf(1)).to.equal(addr1.address)
			expect(await contract.ownerOf(2)).to.equal(addr1.address)
			expect(await contract.ownerOf(3)).to.equal(addr1.address)
			expect(await contract.ownerOf(4)).to.equal(addr1.address)
			expect(await contract.ownerOf(5)).to.equal(addr1.address)

			// Form a band
			await contract.connect(addr1).formBand('Amazing band', 'Blues', 1, 2, 3, 4, 5)

			const band = await contract.getBand(6)
			expect(band.name).to.equal('Amazing band')
			expect(band.bandType).to.equal('Blues')
			expect(band.fanCount).to.be.within(0, 100)
			expect(band.buzzPoints).to.be.within(0, 100)
			expect(band.vocalistId).to.equal(1)
			expect(band.leadGuitarId).to.equal(2)
			expect(band.rhythmGuitarId).to.equal(3)
			expect(band.bassId).to.equal(4)
			expect(band.drumsId).to.equal(5)

			// I own the bands but I don't own anymore the single artists (owned by the contract)
			// Otherwise I could transfer them.
			// If I want to own them I need to disband the band

			// Band is owned by the user
			expect(await contract.ownerOf(6)).to.equal(addr1.address)

			// Artists are owned by the contract
			expect(await contract.ownerOf(1)).to.equal(contract.address)
			expect(await contract.ownerOf(2)).to.equal(contract.address)
			expect(await contract.ownerOf(3)).to.equal(contract.address)
			expect(await contract.ownerOf(4)).to.equal(contract.address)
			expect(await contract.ownerOf(5)).to.equal(contract.address)
		})
	})

	describe('Test disbandBand function', () => {
		it('disbandBand success', async function () {
			await contract.connect(addr1).mintArtist('Vocalist 1', 0) // VOCALIST
			await contract.connect(addr1).mintArtist('Lead Guitar 1', 1) // LEAD_GUITAR
			await contract.connect(addr1).mintArtist('Rhythm Guitar 1', 2) // RHYTHM_GUITAR
			await contract.connect(addr1).mintArtist('Bass 1', 3) // BASS
			await contract.connect(addr1).mintArtist('Drums 1', 4) // DRUMS

			// Form a band
			await contract.connect(addr1).formBand('Amazing band', 'Blues', 1, 2, 3, 4, 5)
			expect(await contract.ownerOf(1)).to.equal(contract.address)
			expect(await contract.ownerOf(2)).to.equal(contract.address)
			expect(await contract.ownerOf(3)).to.equal(contract.address)
			expect(await contract.ownerOf(4)).to.equal(contract.address)
			expect(await contract.ownerOf(5)).to.equal(contract.address)

			// Disband it and take back all
			// At the moment the "burn" method is implemented
			await contract.connect(addr1).disbandBand(6)

			// Artists are owned by the user again
			expect(await contract.ownerOf(1)).to.equal(addr1.address)
			expect(await contract.ownerOf(2)).to.equal(addr1.address)
			expect(await contract.ownerOf(3)).to.equal(addr1.address)
			expect(await contract.ownerOf(4)).to.equal(addr1.address)
			expect(await contract.ownerOf(5)).to.equal(addr1.address)

			await expect(contract.ownerOf(6)).to.be.revertedWith('ERC721: owner query for nonexistent token')
			await expect(contract.getBand(6)).to.be.revertedWith('token does not exist')
		})
	})
})
