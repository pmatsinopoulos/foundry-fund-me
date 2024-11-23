// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeScript is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();

        FundMe fundMe = FundMe(mostRecentlyDeployed);
        fundMe.fund{value: SEND_VALUE}();

        vm.stopBroadcast();

        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run(address mostRecentlyDeployed) external {
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawScript is Script {}
