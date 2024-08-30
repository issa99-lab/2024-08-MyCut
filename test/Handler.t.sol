// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {ContestManager} from "../src/ContestManager.sol";
import {Pot} from "../src/Pot.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";

contract Handler is Test {
    /*ContestManager contestManager;
    Pot pot;
    address manager = makeAddr("mng");
    address[] public contests;
    address contest;
    ERC20Mock token;

    constructor(ContestManager _contestManager) {
        contestManager = _contestManager;
    }

    function createContest(
        address[] memory _players,
        uint256[] memory _rewards,
        uint256 _totalRewards
    ) public {
        uint256 startingContLength = contests.length;
        uint256 startingRewardsContest1 = 0;
        uint256 startingRewardsContest2 = 0;

        vm.startPrank(manager);
        address contest1 = contestManager.createContest(
            _players,
            _rewards,
            token,
            _totalRewards
        );
        address contest2 = contestManager.createContest(
            _players,
            _rewards,
            token,
            _totalRewards
        );
        vm.stopPrank();

        uint256 endingContLength = contests.length;
        uint256 endingRewardsContest1 = contestManager
            .getContestRemainingRewards(contest1);
        uint256 endingRewardsContest2 = contestManager
            .getContestRemainingRewards(contest2);

        assertEq(endingContLength, 2);
        assertEq(startingContLength, 0);
        assert(startingRewardsContest1 < endingRewardsContest1);
        assert(endingRewardsContest2 > startingRewardsContest2);
    }

    function fundContest(uint256 _index) public {
        //Manager should have some funds to pay
        pot = ERPot(contests[_index]);
        token = pot.getToken();
        vm.startPrank(manager);
        contestManager.fundContest(_index);
        vm.stopPrank();
    }*/
}
