// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {ContestManager} from "../src/ContestManager.sol";
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {Pot} from "../src/Pot.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";
import {IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";

contract contesstManager is Test {
    address manager = makeAddr("123");
    address contestManagerContract;

    address player1 = makeAddr("player1");
    address player2 = makeAddr("player2");
    address[] players = [player1, player2];
    uint256 public constant STARTING_USER_BALANCE = 1000 ether;
    ERC20Mock weth;
    address contest;
    address[] totalContests;
    uint256[] rewards = [3, 1];
    address user = makeAddr("user");
    uint256 totalRewards = 4;

    function setUp() public {
        vm.startPrank(manager);
        // DeployContestManager deploy = new DeployContestManager();
        contestManagerContract = address(new ContestManager());
        weth = new ERC20Mock();
        // console.log("User Address: ", user);
        //  manager) = deploy.run();
        console.log("Contest Manager Address 1: ", address(manager));
        vm.stopPrank();
    }

    modifier mintAndApproveTokens() {
        console.log("Minting tokens to: ", user);
        vm.startPrank(user);
        ERC20Mock(weth).mint(user, STARTING_USER_BALANCE);
        ERC20Mock(weth).approve(manager, STARTING_USER_BALANCE);
        console.log("Approved tokens to: ", address(manager));
        vm.stopPrank();
        _;
    }

    function testCanCreatePot() public mintAndApproveTokens {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            4
        );
        totalContests = ContestManager(contestManagerContract).getContests();
        vm.stopPrank();
        assertEq(totalContests.length, 1);
    }

    function testFailToCreateContract() public mintAndApproveTokens {
        vm.startPrank(user);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            4
        );
        vm.stopPrank();
    }
}
