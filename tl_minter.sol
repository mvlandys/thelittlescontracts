// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "tl_whitelist.sol";

contract tlMinter is ERC721Enumerable, Ownable {
    // Minting Price
    uint256 public ethPrice = 0.08 ether;

    // Supply variables
    uint256 public maxSupply;
    uint256 public maxPerTxn;
    uint256 public maxPerWallet;

    // Sale state control variables
    bool public burningEnabled;
    bool public whitelistMintingEnabled;
    bool public publicMintingEnabled;
    uint256 public startSaleTimestamp;
    tlWhitelist whitelistContract;

    // Wallet to withdraw to
    address payable public payableWallet;

    // Metadata variables
    string public _baseURI_;
    uint256 private _tokenIds;

    // Track what tier each little is
    mapping(uint256 => uint256) littleTiers;

    constructor() ERC721("TheLittles", "tls") {
        // Initia Dynamic Values (owner can change later)
        whitelistContract = tlWhitelist(
            0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D
        );
        startSaleTimestamp = 1636707600;
        maxSupply = 10000;
        maxPerTxn = 1;
        maxPerWallet = 1;
        _baseURI_ = "https://media.thelittles.io/";
    }

    /** *********************************** **/
    /** ********* Minting Functions ******* **/
    /** *********************************** **/
    function mintTokens(uint256 quantity) private {
        for (uint256 i = 0; i < quantity; i++) {
            _tokenIds++;
            uint256 newTokenId = _tokenIds;
            _safeMint(msg.sender, newTokenId);
            littleTiers[newTokenId] = 4;
        }
    }

    function defaultMintingRules(uint256 value, uint256 quantity) private view {
        require(value == getPrice(quantity), "wrong value");
        require(totalSupply() < maxSupply, "sold out");
        require(totalSupply() + quantity <= maxSupply, "exceeds max supply");
        require(quantity <= maxPerTxn, "exceeds max per txn");
        require(
            balanceOf(msg.sender) + quantity <= maxPerWallet,
            "exceeds max per wallet"
        );
    }

    function mintWhitelist(uint256 quantity) public payable {
        require(whitelistMintingEnabled, "minting not enabled");
        require(
            whitelistContract.whitelist(msg.sender) > 0,
            "You are not on the white list"
        );
        defaultMintingRules(msg.value, quantity);
        mintTokens(quantity);
    }

    function mintPublic(uint256 quantity) public payable {
        require(
            block.timestamp >= startSaleTimestamp,
            "official sale has not started"
        );
        require(publicMintingEnabled, "minting not enabled");
        defaultMintingRules(msg.value, quantity);
        mintTokens(quantity);
    }

    /** *********************************** **/
    /** ********* Owner Variables ******** **/
    /** *********************************** **/
    function setPriceInWei(uint256 _price) public onlyOwner {
        ethPrice = _price;
    }

    function setWhitelistContract(address wl_contract) public onlyOwner {
        whitelistContract = tlWhitelist(wl_contract);
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxPerWallet(uint256 _maxPerWallet) public onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    function setMaxPerTxn(uint256 _maxPerTxn) public onlyOwner {
        maxPerTxn = _maxPerTxn;
    }

    function toggleBurningEnabled() public onlyOwner {
        burningEnabled = !burningEnabled;
    }

    function toggleWhitelistMintingEnabled() public onlyOwner {
        whitelistMintingEnabled = !whitelistMintingEnabled;
    }

    function togglePublicMintingEnabled() public onlyOwner {
        publicMintingEnabled = !publicMintingEnabled;
    }

    function setStartSaleTimestamp(uint256 _startSaleTimestamp)
        public
        onlyOwner
    {
        startSaleTimestamp = _startSaleTimestamp;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        _baseURI_ = _newBaseURI;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(payableWallet).transfer(balance);
    }

    function updateTier(uint256 tokenId, uint256 tier) public onlyOwner {
        littleTiers[tokenId] = tier;
    }

    /** *********************************** **/
    /** *********** Public Read *********** **/
    /** *********************************** **/
    function getPrice(uint256 quantity) public view returns (uint256) {
        return ethPrice * quantity;
    }

    function burn(uint256 tokenId) public {
        require(burningEnabled, "burning enabled");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller is not owner nor approved"
        );
        _burn(tokenId);
    }

    function remainingSupply() public view returns (uint256) {
        return maxSupply - totalSupply();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURI_;
    }
}
