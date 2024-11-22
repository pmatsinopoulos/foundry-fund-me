// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";
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

    function test_fund_WhenWeSendEnoughEthWeUpdateState() public {
        uint256 amount = 10e18;
        uint256 amountFundedBefore = fundMe.getAddressToAmountFunded(address(this));

        // fire
        vm.prank(USER);
        fundMe.fund{value: amount}();

        // check expectations
        uint256 amountFundedAfter = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFundedAfter, amountFundedBefore + amount);

        assertEq(fundMe.getFunder(0), USER);
    }
}
