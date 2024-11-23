// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";

import {FundMe, FundMe__NotOwner} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// address constant PRICE_FEED_CONTRACT_ON_SEPOLIA = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    AggregatorV3Interface priceFeed = new MockV3Aggregator(6, 1);
    DeployFundMe deployFundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant TEST_FUNDING_AMOUNT = 10 ether;

    modifier fundUser(string memory user) {
        address u = makeAddr(user);
        hoax(u, STARTING_BALANCE);
        fundMe.fund{value: TEST_FUNDING_AMOUNT}();

        _;
    }

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIs5() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender); // because FundMeTest (this) is deploying the contract. So, this is the owner.
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function test_fund_WhenEthSentIsLessThanMinimumUSD_ItReverts() public {
        vm.expectRevert();

        // fire
        fundMe.fund();
    }

    function test_fund_WhenWeSendEnoughEthWeRegisterCallerAsFunderWithCorrectAmount() public {
        uint256 amountFundedBefore = fundMe.getAddressToAmountFunded(address(this));

        // fire
        vm.prank(USER);
        fundMe.fund{value: TEST_FUNDING_AMOUNT}();

        // check expectations
        uint256 amountFundedAfter = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFundedAfter, amountFundedBefore + TEST_FUNDING_AMOUNT);
    }

    function test_fund_WhenWeSendEnoughEthWeRegisterCallerAsFunder() public {
        // fire
        vm.prank(USER);
        fundMe.fund{value: TEST_FUNDING_AMOUNT}();

        // check expectations
        assertEq(fundMe.getFunder(0), USER);
    }

    function test_fund_WhenWeSendEnoughEthWe_IncreaseContractBalanceByValueSent() public {
        uint256 balanceBefore = address(fundMe).balance;

        vm.prank(USER);
        fundMe.fund{value: TEST_FUNDING_AMOUNT}();

        uint256 balanceAfter = address(fundMe).balance;

        assertEq(balanceAfter, balanceBefore + TEST_FUNDING_AMOUNT);
    }

    function test_withdraw_IsCalledOnlyByTheOwner() public {
        address peter = makeAddr("peter");
        vm.prank(peter);
        vm.expectRevert(abi.encodeWithSelector(FundMe__NotOwner.selector));
        fundMe.withdraw();
    }

    function test_withdraw_ResetsAmountsForAllFunderAddresses() public fundUser("peter") fundUser("mary") {
        // fire
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // expectations

        assertEq(fundMe.getAddressToAmountFunded(makeAddr("peter")), 0);
        assertEq(fundMe.getAddressToAmountFunded(makeAddr("john")), 0);
    }

    function test_withdraw_ResetFunders() public fundUser("peter") fundUser("john") {
        // fire
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(fundMe.getNumberOfFunders(), 0);
    }

    function test_withdraw_DepositsAllFundsToOwner() public fundUser("peter") fundUser("mary") {
        address owner = fundMe.getOwner();
        uint256 balanceBefore = owner.balance;

        vm.prank(owner);
        fundMe.withdraw();

        uint256 balanceAfter = owner.balance;

        assertEq(balanceAfter, balanceBefore + TEST_FUNDING_AMOUNT * 2);
    }

    function test_withdraw_WithDrawsAllFundsFromContract() public fundUser("peter") fundUser("mary") {
        uint256 balanceBefore = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 balanceAfter = address(fundMe).balance;

        assertEq(balanceAfter, balanceBefore - TEST_FUNDING_AMOUNT * 2);
    }
}
