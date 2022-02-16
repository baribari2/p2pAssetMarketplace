//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.0;

import './TokenOffer.sol';
import './TokenOfferFactory.sol';
import './HeroNFTOffer.sol';
import './HeroNFTFactory.sol';
contract OfferContainer{

    /// @notice Allows for the retreival of offers involving only TokenOffers
    function getPendingTokenOffer(uint256 _pendingTokenOfferId) public view returns(address){
        TokenOfferFactory tokenofferfactory;
        return(address(tokenofferfactory.tokenoffers(_pendingTokenOfferId)));
    }

    /// @notice Allows for the retreival of offers involving only HeroNFTOffers
    function getPendingHeroOffer(uint256 _pendingHeroOfferId) public view returns(address){
        HeroNFTFactory heronftfactory;
        return(address(heronftfactory.heronftoffers(_pendingHeroOfferId)));
    }

    /// @notice Allows for the retreival of offers involving both TokenOffers and HeroNFTOffers
    function getOfferPair(uint256 _pendingTokenOfferId, uint256 _pendingHeroOfferId) public view returns(address, address) {
        TokenOfferFactory tokenofferfactory;
        HeroNFTFactory heronftfactory;

        return(address(tokenofferfactory.tokenoffers(_pendingTokenOfferId)), address(heronftfactory.heronftoffers(_pendingHeroOfferId)));
    }
}