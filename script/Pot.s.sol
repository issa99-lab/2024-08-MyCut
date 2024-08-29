// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {Pot} from "../src/Pot.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";

contract ContestScript is Script {
    Pot public pot;
    address[] players;
    uint256[] rewards;
    ERC20Mock token;
    uint256 totalRewards;

    function run() public {
        vm.startBroadcast();
        pot = new Pot(players, rewards, token, totalRewards);
        vm.stopBroadcast();
    }
}
