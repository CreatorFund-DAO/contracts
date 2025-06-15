// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltySplit is Ownable {
    IERC20 public payoutToken;

    mapping(address => uint256) public shares;
    uint256 public totalShares;

    event PayoutClaimed(address indexed claimant, uint256 amount);

    constructor(address _payoutToken) {
        payoutToken = IERC20(_payoutToken);
    }

    function setShares(address[] calldata recipients, uint256[] calldata percentages) external onlyOwner {
        require(recipients.length == percentages.length, "Mismatched inputs");

        for (uint256 i = 0; i < recipients.length; i++) {
            shares[recipients[i]] = percentages[i];
            totalShares += percentages[i];
        }
    }

    function claimPayout() external {
        uint256 share = shares[msg.sender];
        require(share > 0, "No share assigned");

        uint256 balance = payoutToken.balanceOf(address(this));
        uint256 payout = (balance * share) / totalShares;

        require(payout > 0, "No payout available");
        payoutToken.transfer(msg.sender, payout);

        emit PayoutClaimed(msg.sender, payout);
    }
}
