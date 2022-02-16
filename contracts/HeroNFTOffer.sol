//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
contract HeroNFTOffer {

    address internal owner;
    address internal tokenWanted;
    uint256 internal heroTokenId;
    uint256 internal tokenAmount;
    uint256 public offerId;
    address public seller;
    bool public offerInactive = false;

    IERC721 HERONFT = IERC721(0x5F753dcDf9b1AD9AabC1346614D1f4746fd6Ce5C);

    event OfferCancelled (address seller, uint256 balance, uint256 _tokenId);
    event OfferFilled(address buyer, uint256 balance, address token, uint256 _tokenId, uint256 tokenAmount);
    event BatchOfferFilled(address buyer, uint256 balance, address token, uint256[] _tokenIds, uint256 tokenAmount);

    constructor(address _tokenWanted, uint256 _tokenAmount, address _seller, uint256 _tokenId, uint256 _offerId) {
        owner = msg.sender;
        tokenWanted = _tokenWanted;
        tokenAmount = _tokenAmount;
        seller = _seller;
        heroTokenId = _tokenId;
        offerId = _offerId;

    }

    /// @notice This function allows NFTs to be withdrawn from the pending offer
    /// @param _token is the address of the NFT that is being withdrawn
    /// @param _tokenId is the token ID of the NFT
    function withdrawTokens (address _token, uint256 _tokenId) public {
        require(msg.sender == owner, 'Caller is not the owner');

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC721(_token).transferFrom(address(this), seller, _tokenId);
        }

    }

    /// @notice This is the function that completes the exchange of assets
    /// @param _tokenId is the ID of the NFT being exchanged
    function fill(uint256 _tokenId) public {
        require(hasHero(), "User doesn't have any heroes");
        require(!offerInactive, "Offer is no longer active");

        uint256 balance = HERONFT.balanceOf(address(this));

        HERONFT.transferFrom(seller, msg.sender, _tokenId);
        offerInactive = true;

        emit OfferFilled(msg.sender, balance, tokenWanted, _tokenId, tokenAmount);
    }

    /// @notice This is the function that completes the batch exchange of assets, which saves gas
    /// by allowing users to exchange multiple NFTs at once
    /// @param _tokenIds is an array IDs of the NFTs being exchanged
    function batchFill(uint256[] memory _tokenIds) public {
        require(hasHeros(), "User must have more then one Hero");
        require(!offerInactive, "Offer is no longer actice");

        uint256 balance = HERONFT.balanceOf(address(this));
        offerInactive = true;

        emit BatchOfferFilled(msg.sender, balance, tokenWanted, _tokenIds, tokenAmount);
    }

    /// @notice This function cancels the offer and returns assets
    /// @param _tokenId is the ID of the NFT being exchanged
    function cancel(uint256 _tokenId) public {
        require(hasHero(), "User doesn't have any heroes");
        require(msg.sender == seller);
        uint256 balance = HERONFT.balanceOf(address(this));
        HERONFT.transferFrom(address(this), seller, _tokenId);
        offerInactive = true;
        emit OfferCancelled(seller, balance, _tokenId);
    }

    function hasHero() public view returns (bool) {
        return HERONFT.balanceOf(address(this)) > 0;
    }
    function hasHeros() public view returns (bool) {
        require(HERONFT.balanceOf(address(this)) > 1, "User must have more than one hero");
        return HERONFT.balanceOf(address(this)) > 0;
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x9c9db2ed, from, to, tokenId));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransferFrom: failed");
    }

}