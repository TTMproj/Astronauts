// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Astronauts is ERC721, Ownable {
    uint256 public totalMinted = 0;
    uint256 public mintingPrice = 0.01 ether;
    uint256 public totalNFT = 300;
    string public baseURI;

    uint256[] public mintedTokens;
    address nftMarketPlaceAddress;
    IERC20 public erc20Token;
    uint256 public airdropTokenAmount;
    address public finDepartmentWallet;
    bool public allowPublicMint;

    constructor(
        string memory _name,
        string memory _symbol,
        address _erc20Token,
        uint256 _airdropTokenAmount,
        string memory _baseUri,
        address _finDepartmentWallet
    ) ERC721(_name, _symbol) Ownable(_msgSender()) {
        baseURI = _baseUri;
        erc20Token = IERC20(_erc20Token);
        airdropTokenAmount = _airdropTokenAmount;
        finDepartmentWallet = _finDepartmentWallet;
        allowPublicMint = false;
    }

    function mintIt(address _to, uint256 _tokenId) private {
        // mint nft
        _safeMint(_to, _tokenId);
        // airdrop token
        erc20Token.transfer(_to, airdropTokenAmount);

        mintedTokens.push(_tokenId);
        totalMinted++;
    }

    // public mint
    function mint(uint256 _tokenId) external payable {
        require(allowPublicMint == true, "Not allowed public mint");
        require(_tokenId > 9, "only Owner can use this tokenId");
        require(_tokenId < 300, "Can't mint this token");
        require(msg.value >= mintingPrice, "Insufficient funds sent");
        require(totalMinted < totalNFT, "All NFTs have been minted");
        require(_ownerOf(_tokenId) == address(0), "Token already exists");
        // check balance of erc20Token in this account is enough to airdrop
        require(
            erc20Token.balanceOf(address(this)) >= airdropTokenAmount,
            "Insufficient token amount in the contract"
        );

        // transfer money from user to fin wallet
        payable(finDepartmentWallet).transfer(msg.value);

        mintIt(msg.sender, _tokenId);
    }

    function giveAway(address _to, uint256 _tokenId) external onlyOwner {
        // require(_tokenId < 10, "Can't give away this tokenId");
        require(_ownerOf(_tokenId) == address(0), "Token already exists");
        require(
            erc20Token.balanceOf(address(this)) >= airdropTokenAmount,
            "Insufficient token in your account"
        );

        mintIt(_to, _tokenId);
    }

    function setAllowPublicMint(bool value) external onlyOwner {
        allowPublicMint = value;
    }

    function approveNFTsMarketPlace() external onlyOwner {
        if (nftMarketPlaceAddress != address(0))
            setApprovalForAll(nftMarketPlaceAddress, true);
    }

    function setBaseURI(string memory _baseUri) external onlyOwner {
        baseURI = _baseUri;
    }

    // overide baseURI
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setMintingPrice(uint256 _mintingPrice) external onlyOwner {
        mintingPrice = _mintingPrice;
    }

    function getAllMintedTokens() external view returns (uint256[] memory) {
        return mintedTokens;
    }
}