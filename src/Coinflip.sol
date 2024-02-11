// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SeedTooShort();

/// @title Coinflip 10 in a Row
/// @author Tianchan Dong
/// @notice Contract used as part of the course Solidity and Smart Contract development
contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable{
    
    string public seed;

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    /// @notice Checks user input against contract generated guesses
    /// @param Guesses a fixed array of 10 elements which holds the user's guesses. The guesses are either 1 or 0 for heads or tails
    /// @return : true if user correctly guesses each flip correctly or false otherwise
    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory contractFlips = getFlips();

        for(uint i = 0; i < Guesses.length; i++) {
            if(Guesses[i] != contractFlips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice : allows the owner of the contract to change the seed to a new one
    /// @param NewSeed: a string which represents the new seed
    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory b = bytes(NewSeed);
        uint seedlength = b.length;
        // Check if the seed is less than 10 characters (This function is given to you)
        if (seedlength < 10){
            revert SeedTooShort();
        }
        seed = NewSeed;
    }

// -------------------- helper functions -------------------- //
    /// @notice This function generates 10 random flips by hashing characters of the seed
    /// @param : No input as only the seed is used for generating the guesses
    /// @return : a fixed 10 element array of type uint8 with only 1 or 0 as its elements
    function getFlips() public view returns(uint8[10] memory){
        bytes memory b = bytes(seed);
        uint seedlength = b.length;
        uint8[10] memory results;
        // Setting the interval for grabbing characters
        uint interval = seedlength / 10;

        for(uint i = 0; i < 10; i++) {
            // Generating a pseudo-random number by hashing together the character and the block timestamp
            uint randomNum = uint(keccak256(abi.encode(b[i*interval], block.timestamp)));
            
            if(randomNum % 2 == 0) { 
                results[i] = 1; 
            } else {
                results[i] = 0;
            }
        }

        return results;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}