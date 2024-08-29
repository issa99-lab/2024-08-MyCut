// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {ContestManager} from "../src/ContestManager.sol";
import {Pot} from "../src/Pot.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";

contract contesstManager is Test {
    ContestManager contestManager;
    Pot pot;
    address manager = makeAddr("mng");
    address con = makeAddr("con");
    address[] players;
    uint256[] rewards;
    ERC20Mock token;
    uint256 totalRewards;

    function setUp() public {}

    function testFailOnlyOwnerCanCreateContests() public {
        vm.startPrank(con);
        contestManager.createContest(players, rewards, token, totalRewards);
        vm.stopPrank();
    }
}
