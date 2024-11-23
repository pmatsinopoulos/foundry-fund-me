// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeScript is Script {
    uint256 public constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed, address buyer) public {
        FundMe fundMe = FundMe(mostRecentlyDeployed);

        vm.prank(buyer);
        fundMe.fund{value: SEND_VALUE}();

        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run(address mostRecentlyDeployed, address buyer) external {
        vm.startBroadcast();

        fundFundMe(mostRecentlyDeployed, buyer);

        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {}
