//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.0;
interface IJewelToken {
    function totalBalanceOf(address _holder) external view returns (uint256);

    function transferAll(address _to) external;

    function lockOf(address _holder) external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address _holder) external view returns (uint256);
}

import './OfferContainer.sol';
import './TokenOfferFactory.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
contract TokenOffer{
    using SafeMath for uint;

    address owner;
    address tokenWanted;
    address public seller;
    uint256 tokenAmount;
    uint256 public tokenOfferId;
    bool public offerInactive = false;
    uint256 fee = 200;

    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);
    IERC20 GREENEGG = IERC20(0x6d605303e9Ac53C59A3Da1ecE36C9660c7A71da5);
    IERC20 GREYEGG = IERC20(0x95d02C1Dc58F05A015275eB49E107137D9Ee81Dc);
    IERC20 BLUEEGG = IERC20(0x9678518e04Fe02FB30b55e2D0e554E26306d0892);
    IERC20 YELLOWEGG = IERC20(0x3dB1fd0Ad479A46216919758144FD15A21C3e93c);
    IERC20 GOLDENEGG = IERC20(0x9edb3Da18be4B03857f3d39F83e5C6AAD67bc148);

    event OfferCancelled (address seller, uint256 balance);
    event OfferFilled(address buyer, uint256 balance, address token, uint256 tokenAmount);
    constructor (address _seller, address _tokenWanted, uint256 _tokenAmount, uint256 _tokenOfferId) {
        seller = _seller;
        owner = msg.sender;
        tokenWanted = _tokenWanted;
        tokenAmount = _tokenAmount;
        tokenOfferId = _tokenOfferId;

    }

    /// @notice This function allows tokens to be withdrawn from the pending offer
    /// @param _token is the address of the token that is being withdrawn
    function withdrawTokens(address _token) public {
        require (msg.sender == owner, 'Caller is not the owner');

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(msg.sender).transfer(address(this).balance);
        } else if(IERC20(_token).balanceOf(address(this)) > 0){
            uint256 balance = IERC20(_token).balanceOf(payable(address(this)));
            payable(msg.sender).transfer(balance);
        }
    }

    /// @notice This is the function that completes the exchange of assets
    function fill() public {
        require(hasJewel() ||
                hasGreenEgg() ||
                hasGreyEgg() ||
                hasBlueEgg()||
                hasYellowEgg() ||
                hasGoldenEgg(), "no Token balance");
        require(!offerInactive, "Offer is no longer active");

        uint256 balance = JEWEL.totalBalanceOf(address(this)).add(
                          GREENEGG.balanceOf(address(this))).add(
                          GREYEGG.balanceOf(address(this))).add(
                          BLUEEGG.balanceOf(address(this))).add(
                          YELLOWEGG.balanceOf(address(this))).add(
                          GOLDENEGG.balanceOf(address(this)));
        uint256 offerFee = (tokenAmount / 10000) * fee;
        uint256 amountAfterFee = tokenAmount - offerFee;

        safeTransferFrom(tokenWanted, msg.sender, owner, offerFee);

        if (GREENEGG.balanceOf(msg.sender) > 0) {
            safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        } else if (GREYEGG.balanceOf(msg.sender) > 0) {
            safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        } else if (BLUEEGG.balanceOf(msg.sender) > 0) {
            safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        } else if (YELLOWEGG.balanceOf(msg.sender) > 0) {
            safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        } else if (GOLDENEGG.balanceOf(msg.sender) > 0) {
            safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        } else if (JEWEL.totalBalanceOf(msg.sender) > 0) {
            JEWEL.transferAll(msg.sender);
        }

        offerInactive = true;
        emit OfferFilled(msg.sender, balance, tokenWanted, tokenAmount);

        ///@dev add a statement that removes this offer from the `TokenOfferFactory` pending offer storage

    }

    /// @notice This function cancels the offer and returns assets
    function cancel() public {
        require(hasJewel(), "no JEWEL balance");
        require(hasGreenEgg(), "no JEWEL balance");
        require(hasGreyEgg(), "no JEWEL balance");
        require(hasBlueEgg(), "no JEWEL balance");
        require(hasYellowEgg(), "no JEWEL balance");
        require(hasGoldenEgg(), "no JEWEL balance");
        require(msg.sender == seller);
        uint256 balance = JEWEL.totalBalanceOf(address(this)).add(
                          GREENEGG.balanceOf(address(this))).add(
                          GREYEGG.balanceOf(address(this))).add(
                          BLUEEGG.balanceOf(address(this))).add(
                          YELLOWEGG.balanceOf(address(this))).add(
                          GOLDENEGG.balanceOf(address(this)));
        JEWEL.transferAll(seller);
        offerInactive = true;
        emit OfferCancelled(seller, balance);
    }

    function hasJewel() public view returns (bool) {
        return JEWEL.totalBalanceOf(address(this)) > 0;
    }
    function hasGreenEgg() public view returns (bool) {
        return GREENEGG.balanceOf(address(this)) > 0;
    }
    function hasGreyEgg() public view returns (bool) {
        return GREYEGG.balanceOf(address(this)) > 0;
    }
    function hasBlueEgg() public view returns (bool) {
        return BLUEEGG.balanceOf(address(this)) > 0;
    }
    function hasYellowEgg() public view returns (bool) {
        return YELLOWEGG.balanceOf(address(this)) > 0;
    }
    function hasGoldenEgg() public view returns (bool) {
        return GOLDENEGG.balanceOf(address(this)) > 0;
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
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransferFrom: failed");
    }
}