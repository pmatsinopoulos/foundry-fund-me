// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// address constant PRICE_FEED_CONTRACT_ON_SEPOLIA = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
import {MockV3Aggregator} from "@chainlink/contracts/v0.8/tests/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    AggregatorV3Interface priceFeed = new MockV3Aggregator(6, 1);
    DeployFundMe deployFundMe;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIs5() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        console.log("***************** msg.sender = %s", msg.sender);
        assertEq(fundMe.getOwner(), msg.sender); // because FundMeTest (this) is deploying the contract. So, this is the owner.
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
