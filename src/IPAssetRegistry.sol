// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIPAssetRegistry {
    function registerIP(
        address nftAddress,
        uint256 tokenId,
        string calldata ipMetadataURI,
        bytes32 ipMetadataHash,
        string calldata nftMetadataURI,
        bytes32 nftMetadataHash
    ) external returns (address ipAssetAccount);
}
