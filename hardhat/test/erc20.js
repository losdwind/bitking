const { expect } = require('chai');
const { ethers } = require('hardhat');


describe("BaseERC20", async () => {
    let contract;
    let accounts, owner;
    const name = 'BaseERC20';
    const symbol = 'BERC20';
    const decimals = 18;
    const totalSupply = ethers.utils.parseUnits('1.0', decimals).mul(100000000); // 100 million
    const randomAccount = ethers.Wallet.createRandom();
    const randomAddr = randomAccount.address;


    async function init() {
        // 部署 BaseERC20
        accounts = await ethers.getSigners();
        owner = accounts[0];

        const factory = await ethers.getContractFactory('BaseERC20');
        contract = await factory.deploy(name, symbol,decimals, totalSupply);
        await contract.deployed();
    }

    beforeEach(async () => {
        await init();
    })

    describe("base", async () => {
        it("name", async () => {
            expect(await contract.name()).to.equal(name);
        });

        it("symbol", async () => {
            expect(await contract.symbol()).to.equal(symbol);
        });

        it("decimals", async () => {
            expect(await contract.decimals()).to.equal(decimals);
        });
    })

    describe("totalSupply ", async () => {
        it("totalSupply", async () => {
            const _totalSupply = await contract.totalSupply();
            expect(_totalSupply).to.equal(totalSupply);
        });
    });

    describe("balanceOf ", async () => {
        it("balanceOf", async () => {
            const balance = await contract.balanceOf(owner.address);
            expect(balance).to.equal(totalSupply);
        });
    });

    describe("transfer", function () {
        it("Should fail if sender doesn’t have enough balance", async function () {
            const curBalance = await contract.balanceOf(owner.address);
            const transAmount = curBalance.add(1);

            await expect(
                contract.connect(owner).transfer(randomAddr, transAmount)
            ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
        });

        it("Should update balances after transfers", async function () {
            // Transfer 100 tokens from owner to randomAddr.
            await expect(
                contract.transfer(randomAddr, 100)
            ).to.changeTokenBalances(contract, [owner.address, randomAddr], [-100, 100]);
        });
    });

    describe('Approval', function () {
        it('Should set an approval amount for delegated tranfer', async function () {
            const amount = 100
            await contract.connect(owner).approve(randomAddr, amount);
            expect(await contract.allowance(owner.address, randomAddr)).to.equal(amount);
        });
    });

    describe('Allowance', function () {
        // 'Should set an approval amount for delegated tranfer',see above case

        it('Should update allowance after transferFrom', async function () {
            let sender = accounts[1];
            let recipient = randomAddr;
            let approveAmount = 100;
            let usedAmout = approveAmount/2;
            let leftAmount = approveAmount - usedAmout;

            await contract.connect(owner).approve(sender.address, approveAmount);

            await contract.connect(sender).transferFrom(owner.address, recipient, usedAmout);

            const afterAllowance = await contract.allowance(owner.address, sender.address);

            expect(afterAllowance).to.equal(leftAmount);
        });
    });

    describe('transferFrom', function () {
        // 'Should update allowance after transferFrom',see above case

        it('Should transfer the tokens from sender to recipient', async function () {
            let sender = accounts[1];
            let recipient = randomAddr;
            let amount = 100;

            await contract.connect(owner).approve(sender.address, amount);
            await contract.connect(sender).transferFrom(owner.address, recipient, amount);

            expect(await contract.balanceOf(recipient)).to.equal(amount);
        });

        it('Should fail if sender doesn’t have enough tokens', async function () {
            let sender = accounts[1];
            let recipient = randomAddr;
            let allowanceAmount = totalSupply.add(1);

            await contract.connect(owner).approve(sender.address, allowanceAmount);
            await expect(contract.connect(sender).transferFrom(owner.address, recipient, allowanceAmount)).to.be.revertedWith('ERC20: transfer amount exceeds balance');
        });

        it('Should fail if trying to transfer more tokens than approved', async function () {
            let sender = accounts[1];
            let recipient = randomAddr;
            let allowanceAmount = 100;
            let transferAmount = 101; // more than approved

            await contract.connect(owner).approve(sender.address, allowanceAmount);
            await expect(contract.connect(sender).transferFrom(owner.address, recipient, transferAmount)).to.be.revertedWith('ERC20: transfer amount exceeds allowance');
        });
    });
});