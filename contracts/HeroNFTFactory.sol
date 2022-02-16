//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.0;

import './HeroNFTOffer.sol';
contract HeroNFTFactory {
    uint256 private heroOfferId;

    mapping (uint256 => PendingOffer) internal pendingherooffers;

    HeroNFTOffer[] public heronftoffers;
    struct PendingOffer {
        HeroNFTOffer heronftoffer;
    }
    PendingOffer pendingherooffer;

    event OfferCreated(address offerAddress, address tokenWanted, uint256 tokenAmount, uint256 tokenId, uint256 offerId);

    /// @notice This is the function that creates an offer
    /// @param _tokenWanted is the address of the desired token
    /// @param _tokenAmount is how much of the desired token the user would like
    /// @param _seller is the address of the person that is selling the token
    /// @param _tokenId is the ID of the desired token
    function createHeroOffer(address _tokenWanted, uint256 _tokenAmount, address _seller, uint256 _tokenId) public {
        HeroNFTOffer  offer = new HeroNFTOffer(_tokenWanted, _tokenAmount, _seller, _tokenId, heroOfferId);
        pendingherooffer.heronftoffer = offer;
        heronftoffers.push(offer);

        pendingherooffers[heroOfferId] = pendingherooffer;
        heroOfferId++;

        emit OfferCreated(address(pendingherooffer.heronftoffer), _tokenWanted, _tokenAmount, _tokenId, offer.offerId());

    }

    function activeHeroOffersByOwner() public view returns(HeroNFTOffer[] memory){
        HeroNFTOffer[] memory myOffers = new HeroNFTOffer[](heronftoffers.length);

        uint256 currOfferCount;

        for(uint256 i = 0; i < heronftoffers.length; i++) {
            if (pendingherooffers[i].heronftoffer.hasHero() && !pendingherooffers[i].heronftoffer.offerInactive()) {
                if(pendingherooffers[i].heronftoffer.seller() == msg.sender) {
                    myOffers[currOfferCount++] = heronftoffers[i];
                }
            }
        }

        return (myOffers);
    }
    function activeHeroOffers() public view returns(HeroNFTOffer[] memory) {
        HeroNFTOffer[] memory offers = new HeroNFTOffer[](heronftoffers.length);

        uint256 currOfferCount;

        for(uint256 i = 0; i < heronftoffers.length; i++) {
            if (pendingherooffers[i].heronftoffer.hasHero() && !pendingherooffers[i].heronftoffer.offerInactive()) {
                offers[currOfferCount++] = heronftoffers[i];
            }
        }

        return (offers);
    }

    function returnOffer(uint256 _offerId) internal view returns(HeroNFTOffer){
        return (pendingherooffers[_offerId].heronftoffer);
    }


}