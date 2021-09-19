const fs = require('fs')
const path = require('path')
const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('RockburgNFT', function () {
	it('correctly generates SVG from metadata', async function () {
		const mockSVG = fs.readFileSync(path.join(__dirname, '/mock/ShpigfordNFT.svg'), 'utf-8').trim()
		const RockburgNFT = await ethers.getContractFactory('RockburgNFT')
		const contract = await RockburgNFT.deploy()
		await contract.deployed()

		const mintTx = await contract.mintWithStats('Shpigford', 'Coder', 99, 99, 99, 99)

		// wait until the transaction is mined
		await mintTx.wait()

		const tokenURI = await contract.tokenURI(1)
		const metadata = JSON.parse(base64Decode(strAfter(tokenURI, 'data:application/json;base64,')))
		const generatedSVG = base64Decode(strAfter(metadata.image, 'data:image/svg+xml;base64,'))

		expect(metadata.name).to.equal('Musician #1')
		expect(metadata.description).to.equal('Rockburg is a WIP card game on the blockchain.')
		expect(generatedSVG).to.equal(mockSVG)
	})
})

const strAfter = (haysack, needle) => haysack.split(needle).pop()
const base64Decode = string => Buffer.from(string, 'base64').toString('utf-8')
