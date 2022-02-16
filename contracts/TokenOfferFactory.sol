//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import'./TokenOffer.sol';
import './HeroNFTOffer.sol';
import './TokenOffer.sol';
import './OfferContainer.sol';

contract TokenOfferFactory{
    uint256 private offerId;

    TokenOffer[] public tokenoffers;

    event OfferCreated(address offerAddress, address tokenWanted, uint256 amountWanted, uint256 _offerId);

    mapping (uint256 => PendingOffer) internal pendingoffers;


    struct PendingOffer {
        TokenOffer tokenoffer;
    }
    PendingOffer pendingTokenOffer;

    /// @notice This is the function that creates an offer
    /// @param _token is the address of the desired token
    /// @param _amount is how much of the desired token the user would like
    /// @param _seller is the address of the person that is selling the token
    function createTokenOffer(address _token, uint256 _amount, address _seller) public {
        TokenOffer offer = new TokenOffer(_seller, _token, _amount, offerId);
        pendingTokenOffer.tokenoffer = (offer);
        tokenoffers.push(offer);

        pendingoffers[offerId] = pendingTokenOffer;

        emit OfferCreated(address(offer), _token, _amount, offerId);
        offerId++;
    }


    function activeTokenOffersByOwner() public view returns (TokenOffer[] memory) {
        TokenOffer[] memory myOffers = new TokenOffer[](tokenoffers.length);

        uint256 currOfferCount;

        for(uint256 i = 0; i < tokenoffers.length; i++) {
            if (pendingoffers[i].tokenoffer.hasJewel() ||
                pendingoffers[i].tokenoffer.hasGreenEgg() ||
                pendingoffers[i].tokenoffer.hasGreyEgg() ||
                pendingoffers[i].tokenoffer.hasBlueEgg() ||
                pendingoffers[i].tokenoffer.hasYellowEgg() ||
                pendingoffers[i].tokenoffer.hasGoldenEgg() &&
                !pendingoffers[i].tokenoffer.offerInactive()) {
                if(pendingoffers[i].tokenoffer.seller() == msg.sender) {
                    myOffers[currOfferCount++] = tokenoffers[i];
                }
            }
        }

        return (myOffers);

    }
    function activeTokenOffers() public view returns (TokenOffer[] memory) {
        TokenOffer[] memory offers = new TokenOffer[](tokenoffers.length);

        uint256 currOfferCount;

        for(uint256 i = 0; i < tokenoffers.length; i++) {
            if (pendingoffers[i].tokenoffer.hasJewel() ||
                pendingoffers[i].tokenoffer.hasGreenEgg() ||
                pendingoffers[i].tokenoffer.hasGreyEgg() ||
                pendingoffers[i].tokenoffer.hasBlueEgg() ||
                pendingoffers[i].tokenoffer.hasYellowEgg() ||
                pendingoffers[i].tokenoffer.hasGoldenEgg() &&
                !pendingoffers[i].tokenoffer.offerInactive()) {
                offers[currOfferCount++] = tokenoffers[i];
            }
        }

        return(offers);
    }

    function returnOffer(uint256 _offerId) internal view returns(TokenOffer){
        return (pendingoffers[_offerId].tokenoffer);
    }
}

