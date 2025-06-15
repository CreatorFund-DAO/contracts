// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorFundToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

contract CreatorFundDAO is Ownable {
    CreatorFundToken public fundToken;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event ProposalExecuted(uint256 indexed proposalId);

    struct Proposal {
        string description;
        bool executed;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    constructor(address creator, string memory tokenName, string memory tokenSymbol) {
        fundToken = new CreatorFundToken(tokenName, tokenSymbol);
        transferOwnership(creator);
    }

    function createProposal(string memory description) external returns (uint256) {
        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.description = description;

        emit ProposalCreated(proposalCount, description);
        return proposalCount;
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        proposal.hasVoted[msg.sender] = true;

        uint256 voterPower = fundToken.balanceOf(msg.sender);
        require(voterPower > 0, "No voting power");

        if (support) {
            proposal.yesVotes += voterPower;
        } else {
            proposal.noVotes += voterPower;
        }
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");

        // Placeholder → integrate with Story/Tomo or external modules here
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }

    function mintTokens(address to, uint256 amount) external onlyOwner {
        fundToken.mint(to, amount);
    }
}

