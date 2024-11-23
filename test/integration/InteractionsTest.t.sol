// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMeScript} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    FundMeScript fundMeScript;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 20 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        fundMeScript = new FundMeScript();
        vm.deal(USER, STARTING_BALANCE);
    }

    function test_Interactions_fundFundMe_FundsUsingMostRecentlyDeployed_With_SEND_VALUE() public {
        // fire
        fundMeScript.fundFundMe(address(fundMe), USER);

        assertEq(fundMe.getAddressToAmountFunded(USER), 0.01 ether);
    }
}
