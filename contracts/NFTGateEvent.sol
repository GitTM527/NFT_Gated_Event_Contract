// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTGatedEvent {
    IERC721 public nftContract; // Corrected naming
    address public owner;
    uint256 public maxParticipants; // Adjusted naming for consistency

    struct Access {
        address participant;
        uint256 tokenId;
        uint256 eventTime;
    }

    // Events for event creation and access granting
    event CreateEvent(
        address indexed creator,
        uint256 indexed eventId,
        uint256 indexed tokenId,
        uint256 eventTime
    );
    event GrantAccessToEvent(
        address indexed participant,
        uint256 indexed tokenId
    );

    // Mappings to track event registrations and participant access
    mapping(address => Access) public grantAccess;
    mapping(uint256 => bool) public eventRegistration; // Tracks whether an event is created
    mapping(uint256 => uint256) public eventParticipants; // Tracks participant count for each event
    mapping(address => uint256) public userEventCount; // Tracks the number of events a user has created

    constructor(address _nftContract, uint256 _maxParticipants) {
        nftContract = IERC721(_nftContract); // Clarified contract input
        owner = msg.sender;
        maxParticipants = _maxParticipants; // Initialize max participants
    }

    // Modifier to check if the caller is an NFT holder
    modifier onlyNFTHolder(uint256 tokenId) {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not an NFT holder");
        _;
    }

    // Function to create a gated event
    function createEvent(uint256 eventId, uint256 tokenId, uint256 eventTime)
        external
        onlyNFTHolder(tokenId)
    {
        // Ensure event is unique and has not started yet
        require(eventTime > block.timestamp, "Event must start in the future");
        require(!eventRegistration[eventId], "Event ID already registered");

        // Register the event
        eventRegistration[eventId] = true;
        eventParticipants[eventId] = 0; // Initialize participant count

        // Increment the user's event count
        userEventCount[msg.sender] += 1;

        // Emit the event creation
        emit CreateEvent(msg.sender, eventId, tokenId, eventTime);
    }

    // Function to grant access to a participant based on NFT ownership
    function grantAccessToEvent(uint256 eventId, uint256 tokenId) public {
        // Ensure event has not started and can accommodate more participants
        require(eventRegistration[eventId], "Event is not registered");
        require(eventParticipants[eventId] < maxParticipants, "Event is full");
        
        // Ensure the participant is an NFT holder
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not an NFT holder");

        // Grant access to the participant
        grantAccess[msg.sender] = Access(msg.sender, tokenId, block.timestamp);

        // Increment the participant count
        eventParticipants[eventId] += 1;

        // Emit the access granted event
        emit GrantAccessToEvent(msg.sender, tokenId);
    }
}

