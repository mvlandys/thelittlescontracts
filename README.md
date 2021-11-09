## The Littles Smart Contracts

**tl_whitelist.sol**

 - This is the contract that maintains the whitelist.
 - We will populate the constructor function with a list of addresses from our website once the whitelist has closed
 - I have added the ability to dynamically add and remove whitelist entries

**tl_minter.sol**

 - This is the contract that mints the NFTs
 - The contract also maintains a list of each token and its current tier (they all start at tier 4)
 - We can dynamically change the following values:
	 - **Price** – Default set to 0.08 ETH
	 - **Whitelist Contract** – In the event we want to use a different whitelist in the future
	 - **Max Supply** – Default set to 10,000
	 - **Max Per Wallet** – How many NFTs per wallet are allowed. We will change this between whitelist minting and public minting
	 - **Max Per Transaction**– How many NFTs can be minted in one transaction. We will change this between whitelist minting and public minting
	 - **Max Per Wallet** – How many NFTs can be stored in a wallet. We will change this between whitelist minting and public minting
 - Minting specific functions & variables:
	 - **Toggle Whitelist Minting** – This function allows us to allow or stop the ability to mint if you are on the whitelist
	 - **Toggle Public Minting** – This function allows us to control when the public can mint
	 - **Set Start Sale Timestamp** – This variable set the epoch timestamp of the start of the public sale. This must be used in conjunction with the toggle public minting function

**Additional details:**

Due to the dynamic nature of our NFTs and the way they were designed graphically we have opted to use a non-ipfs host (AWS Cloudfront). We have the ability to move to another storage platform such as IPFS or Arweave in the future.

The evolution functionality will be done on another contract once the finer details are defined and agreed upon. How this would work is the website will interact with the evolution contract, which will validate the NFT via the official contract and then update the tier on the official contract and finally update the metadata and nft image on our API

I have chosen not to include a provenance hash as our NFTs are always changing due to the evolution functionality, the provenance hash is designed for NFT drops where the metadata and images do not change and guarantees that the rare NFTs were not predicable or gamed by the contract owners.