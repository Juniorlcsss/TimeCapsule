//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TimeCapsule is ERC721Enumerable, Ownable, ReentrancyGuard{
    struct Capsule{
        address sender;
        uint unlockTime;
        uint currTime;
        string item;    //make as a string for now
        address[] recipients;
        bool isOpen;
    }

    Capsule[] public capsules;
    uint public capsuleCount;

    event CompleteCapsule(uint indexed id, string item, uint time,  address[] recipients, address sender);
    event CapsuleOpen(uint indexed id);


    //constructor
    constructor() ERC721("TimeCapsule", "TimeCapsule"){
        //leave empty for now
    }

    //create a new capsule
    function createCapsule(string memory item, uint unlockTime, address[] memory recipients) public onlyOwner{
        //check date
        require(unlockTime > block.timestamp, "Invalid unlock time, please make it at a later date.");

        //
        capsuleCount++;
        capsules[capsuleCount] = Capsule(msg.sender, unlockTime, block.timestamp, item, recipients, false);
        _mint(msg.sender, capsuleCount);

        emit CompleteCapsule(capsuleCount, item, unlockTime, recipients, msg.sender);
    }

    function unlockCapsule(uint id) public nonReentrant{
        Capsule storage capsule = capsules[id];
        
        //checks
        require(block.timestamp >= capsule.unlockTime, "Capsule is still locked.");
        require(!capsule.isOpen, "Capsule already open");
        require(isReciever(msg.sender, capsule.recipients), "You are not the recipient of this capsule.");

        //open it
        capsule.isOpen = true;
        emit CapsuleOpen(id);
        return;
    }

    function isReciever(address user, address[] memory recipients) private pure returns (bool){
        for(uint i=0; i<recipients.length; i++){
            if(recipients[i] == user){
                return true;
            }
        }
        return false;
    }
}