// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {ContestManager} from "../src/ContestManager.sol";
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {Pot} from "../src/Pot.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";

contract contesstManager is Test {
    ContestManager contestManager;
    Pot pot;
    ERC20Mock token;

    address con = makeAddr("con");
    address player1 = makeAddr("ply");
    address player2 = makeAddr("ply2");
    address[] players;

    uint256[] rewards;
    uint256 ply1Reward = 5;
    uint256 ply2Reward = 2;
    uint256 totalRewards = 7;
    uint256 index;
    address contest;

    function setUp() public {
        token = new ERC20Mock();
        token.mint(address(this), totalRewards + 3);
        // token.mint(address(this), totalRewards + 3);

        contestManager = new ContestManager();
    }

    modifier contestCreated() {
        vm.startPrank(address(this));
        players.push(player1);
        players.push(player2);
        rewards.push(ply1Reward);
        rewards.push(ply2Reward);

        address x = contestManager.createContest(
            players,
            rewards,
            token,
            totalRewards
        );
        token.approve(address(this), address(x), totalRewards); //should approve first
        contestManager.fundContest(0); //fund

        /* contestManager.createContest(players, rewards, token, totalRewards);
        token.approve(address(this), potIndexAddy, totalRewards); //should approve first
        contestManager.fundContest(index + 1);*/

        vm.stopPrank();
        _;
    }

    function testFailOnlyOwnerCanCreateContests() public {
        vm.startPrank(con);
        contestManager.createContest(players, rewards, token, totalRewards);
        vm.stopPrank();
    }

    function testManagerCanCreateContest() public {
        vm.startPrank(address(this));
        contestManager.createContest(players, rewards, token, totalRewards);
        vm.stopPrank();
    }

    function testManagerCanFund() public {
        /* _index = bound(_index, 0, 2);
        address potIndexAddy = contestManager.contests(_index);*/
        vm.startPrank(address(this));
        players.push(player1);
        players.push(player2);
        rewards.push(ply1Reward);
        rewards.push(ply2Reward);

        address x = contestManager.createContest(
            players,
            rewards,
            token,
            totalRewards
        );
        Pot potAddress = Pot(payable(x));

        ERC20Mock(token).approve(address(potAddress), totalRewards); //should approve first
        contestManager.fundContest(0); //fund

        assertEq(contestManager.getContestTotalRewards(x), 7);
    }
}
