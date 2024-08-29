// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {ContestManager} from "../src/ContestManager.sol";

contract ContestScript is Script {
    ContestManager public contestManagerr;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        contestManagerr = new ContestManager();
        vm.stopBroadcast();
    }
}
