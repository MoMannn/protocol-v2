// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 * Here we have helper methods and types to enable privacy on the protocol.
 * We cannot user modifier or require everywhere because we there are some intra-contract calls, so the caller is the contract itself.
 * 
 * The privacy features are restricted to the sender or the whitelisted addresses.
 * 
 */

abstract contract PrivacyFeatures {

    string constant RESTRICTION_MESSAGE = "Restriction: Only allowed address valid";
   
    bool public privacyEnabled = true;

    mapping(address => bool) public privacyReadEnabledAddresses;

    function canExposeToRead(address sender) internal view returns (bool) {
        if (privacyEnabled) {
          return (msg.sender == sender) || (privacyReadEnabledAddresses[msg.sender]);
        }
        return true;
    }   
    
    modifier onlyAllowedWhenPrivate(address sender) {
        if (privacyEnabled) {
            require((msg.sender == sender) || (privacyReadEnabledAddresses[msg.sender]) , RESTRICTION_MESSAGE);
        }
        _;
    }

    modifier onlyPrivayEnabledAddresses() {
        require(privacyReadEnabledAddresses[msg.sender], RESTRICTION_MESSAGE);
        _;
    }
   
    function checkIfAddressIsAllowedWhenPrivate(address userAddr) internal view {
        if (privacyEnabled) {
            require((msg.sender == userAddr) || privacyReadEnabledAddresses[msg.sender], RESTRICTION_MESSAGE);
        }
    }

    /*function addressToString(address _addr) internal pure returns (string memory) {
    bytes32 value = bytes32(uint256(uint160(_addr)));
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint256 i = 0; i < 20; i++) {
        str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
        str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
    }
    */

    /*
         _____                 _       
        | ____|_   _____ _ __ | |_ ___ 
        |  _| \ \ / / _ \ '_ \| __/ __|
        | |___ \ V /  __/ | | | |_\__ \
        |_____| \_/ \___|_| |_|\__|___/
    */
    
    event DepositPrivate(
        uint256 id,
        uint16 referralCode 
    ); 

    event WithdrawPrivate(
        uint256 id
    );

    event RepayPrivate(
        uint256 id
    );

    event BorrowPrivate(
        uint256 id,
        uint16 referralCode 
    );

    event FlashLoanPrivate(
        uint256 id,
        uint16 referralCode 
    );

    event ReserveUsedAsCollateralEnabledPrivate(
        uint256 id
    );

    event ReserveUsedAsCollateralDisabledPrivate(
        uint256 id
    ); 

    event SwapPrivate(
        uint256 id
    );

    event RebalanceStableBorrowRatePrivate(
        uint256 id
    );
}