import { ethers, run } from 'hardhat'

const renderers = ['Musician', 'Venue', 'Studio']

async function main() {
	const rendererAddresses = []
	for (const type of renderers) {
		console.log(`Deploying ${type}Renderer contract...`)
		const Renderer = await ethers.getContractFactory(`${type}Renderer`)
		const renderer = await Renderer.deploy()
		await renderer.deployed()

		rendererAddresses.push(renderer.address)
		console.log(`${type}Renderer contract deployed to ${renderer.address}`)
	}

	console.log(`Deploying contract...`)
	const RockburgNFT = await ethers.getContractFactory('RockburgNFT')
	const contract = await RockburgNFT.deploy(...rendererAddresses)

	await contract.deployed()
	console.log(`Contract deployed to ${contract.address}.`)
	console.log(`Verifying contract...`)
	await run('verify:verify', { address: contract.address, constructorArguments: rendererAddresses })
	console.log(`Contract verified.`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error(error)
		process.exit(1)
	})
