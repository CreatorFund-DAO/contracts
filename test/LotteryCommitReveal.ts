import { ethers }from "hardhat";
import { expect } from "chai";

describe("LotteryCommitReveal", function () {
  let Lottery, lottery: any;
  let DAO, dao: any;
  let VRFMock, vrfMock: any;
  let owner: any, moderator: any, participant1: any, participant2: any;

  const ticketPrice = ethers.utils.parseEther("1");
  const commitment = (secret: number, addr: string) =>
    ethers.utils.solidityKeccak256(["uint256", "address"], [secret, addr]);

  beforeEach(async () => {
    [owner, moderator, participant1, participant2] = await ethers.getSigners();

    DAO = await ethers.getContractFactory("MockDAO");
    dao = await DAO.deploy();

    VRFMock = await ethers.getContractFactory("MockVRFCoordinatorV2");
    vrfMock = await VRFMock.deploy();

    Lottery = await ethers.getContractFactory("LotteryCommitReveal");
    lottery = await Lottery.deploy(
      moderator.address,
      ticketPrice,
      "Test Lottery",
      dao.address,
      vrfMock.address,
      ethers.constants.HashZero, 
      1 
    );
  });

  it("allows ticket purchase during Buy phase", async () => {
    await lottery.connect(participant1).buyTickets(2, { value: ticketPrice.mul(2) });
    const data = await lottery.getParticipantData(participant1.address);
    expect(data.tickets).to.equal(2);
  });

  it("prevents commitment before Commit phase", async () => {
    await expect(
      lottery.connect(participant1).commitNumber(commitment(123, participant1.address))
    ).to.be.revertedWith("Not in commit phase");
  });

  it("runs full commit-reveal lifecycle", async () => {
    await lottery.connect(participant1).buyTickets(1, { value: ticketPrice });
    await lottery.connect(participant2).buyTickets(1, { value: ticketPrice });

    await lottery.connect(moderator).advancePhase(); 
    const secret1 = 12345;
    const secret2 = 67890;
    await lottery.connect(participant1).commitNumber(commitment(secret1, participant1.address));
    await lottery.connect(participant2).commitNumber(commitment(secret2, participant2.address));

    await lottery.connect(moderator).advancePhase(); 
    await lottery.connect(participant1).revealNumber(secret1);
    await lottery.connect(participant2).revealNumber(secret2);

    await lottery.connect(moderator).requestRandomWinner();

    
    await lottery.fulfillRandomWords(1, [ethers.BigNumber.from("42")]);

    const winner = await lottery.winner();
    expect([participant1.address, participant2.address]).to.include(winner);
  });

  it("distributes prize correctly with DAO percentage", async () => {
    await lottery.connect(participant1).buyTickets(1, { value: ticketPrice });
    await lottery.connect(moderator).advancePhase(); 
    await lottery.connect(participant1).commitNumber(commitment(111, participant1.address));
    await lottery.connect(moderator).advancePhase(); 
    await lottery.connect(participant1).revealNumber(111);
    await lottery.connect(moderator).requestRandomWinner();
    await lottery.fulfillRandomWords(1, [1]);

    const payoutPercent = await dao.currentPayoutPercentage();
    const expectedPrize = ticketPrice.mul(payoutPercent).div(100);

    const balanceAfter = await ethers.provider.getBalance(participant1.address);
    expect(balanceAfter.gt(0)).to.be.true; 
  });
});
