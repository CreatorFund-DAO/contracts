---

#  **Integration Flow: CreatorFundDAO + Story Protocol**

### **1. Registering the IP with Story Protocol**

When a **creator or the DAO** wants to tokenize their intellectual property:

 **Step 1:** Creator mints an **ERC-721 NFT** representing their creative work (e.g., song, book, film, etc.) → can be minted independently or via Story.

 **Step 2:** **Register NFT as IP Asset** with **Story’s IP Asset Registry** by calling:

```solidity
IIPAssetRegistry(storyRegistryAddress).registerIP(
    nftAddress,
    tokenId,
    ipMetadataURI,
    ipMetadataHash,
    nftMetadataURI,
    nftMetadataHash
);
```

→ **Returns an IP Account (ERC-6551-based)** dedicated to that IP asset.

---

### **2. Fractionalize Ownership → DAO Tokens**

* The **CreatorFundDAO** issues **ERC-20 DAO tokens** to fractionalize ownership of that IP asset.
* These DAO tokens **represent voting power + revenue rights** for that specific IP.

Example:

* DAO mints `1,000,000 $FUND` tokens → 60% to creator, 40% to early supporters.

---

### **3. Revenue Sharing Integration**

* As **Story generates royalties** via the **Royalty Module** (e.g., from licensing, remixes, commercial uses), **royalties flow to the IP Account**.
* DAO uses **RoyaltySplit.sol** to **distribute those royalties proportionally** to \$FUND holders.

→ Example: If the IP earns 10 ETH in licensing revenue → DAO members can **claim their proportional payout** via the contract.

---

### **4. Licensing Management with Story**

* **Story’s Licensing Module** allows the DAO (via governance) to:

  * Set licensing terms (e.g., Creative Commons, PIL)
  * Adjust royalty percentages
  * Dynamically price license minting with **License Hooks**

→ DAO can propose → vote → **adjust licensing dynamically** based on market demand or community input.

---

### **5. Automation with Tomo Agents**

* **Tomo Agents** can:

  * Automatically trigger licensing fee adjustments (via License Hooks)
  * Perform dispute resolution functions
  * Automate governance proposals on behalf of creators or token holders

---

### **6. Onchain Proof + Interoperability**

* Since the IP Asset and its licensing history are stored **onchain**, **any dApp or DAO** can **read and verify**:

  * Who owns it
  * How it’s licensed
  * Revenue history
  * Legal permissions

Story → CreatorFundDAO → Token Holders → Royalties → Onchain Verification → Open Composability

---

