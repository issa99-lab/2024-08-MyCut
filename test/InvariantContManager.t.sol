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
    address player3 = makeAddr("player3");
    address hacker = makeAddr("hacker");
    address[] players = [player1, player2, player3];
    uint256 public constant STARTING_USER_BALANCE = 100e18;
    ERC20Mock weth;
    address contest;
    address[] totalContests;
    uint256[] rewards = [60, 20, 20];
    address user = makeAddr("user");

    uint256 totalRewards = 100;

    function setUp() public {
        vm.startPrank(manager);
        // DeployContestManager deploy = new DeployContestManager();
        contestManagerContract = address(new ContestManager());
        weth = new ERC20Mock();
        ERC20Mock(weth).mint(manager, STARTING_USER_BALANCE);
        // console.log("User Address: ", user);
        //  manager) = deploy.run();
        //console.log("Contest Manager Address 1: ", address(manager));
        vm.stopPrank();
    }

    modifier createFundContest() {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);

        vm.stopPrank;
        _;
    }

    function testCanCreatePot() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        totalContests = ContestManager(contestManagerContract).getContests();
        vm.stopPrank();
        assertEq(totalContests.length, 1);
    }

    function testFailToCreateContract() public {
        vm.startPrank(user);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        vm.stopPrank();
    }

    function testCanFundPot() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);

        assertEq(ERC20Mock(weth).balanceOf(contest), 100);
    }

    function testMoneyExitsManagersAccount() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        uint256 startingBal = ERC20Mock(weth).balance(manager);

        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        uint256 endingBal = ERC20Mock(weth).balance(manager);
        console.log(endingBal);
        assert(endingBal < startingBal);
        assertEq(endingBal, startingBal - 100);
    }

    function testContests() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(1);
        address[] memory contests1 = ContestManager(contestManagerContract)
            .getContests();
        uint256 length = contests1.length;
        assertEq(length, 2);
    }

    function testClaim() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        vm.stopPrank();
        vm.startPrank(player1);
        Pot(contest).claimCut();
        vm.stopPrank();
        vm.startPrank(player2);
        Pot(contest).claimCut();
        vm.stopPrank();
        assertEq(Pot(contest).getRemainingRewards(), totalRewards - 80);

        console.log(Pot(contest).getRemainingRewards());
    }

    function testCheckCut() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        vm.stopPrank();
        vm.startPrank(hacker);
        uint256 cut = Pot(contest).checkCut(player1);
        vm.stopPrank();
        assertEq(cut, rewards[0]);
    }

    function testFailHackerClaim() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        vm.stopPrank();
        vm.startPrank(manager);
        Pot(contest).claimCut();
        vm.stopPrank();
    }

    /* function testManagerCanCloseContest() public {
        vm.startPrank(manager);
        contest = ContestManager(contestManagerContract).createContest(
            players,
            rewards,
            IERC20(ERC20Mock(weth)),
            totalRewards
        );
        ERC20Mock(weth).approve(contestManagerContract, totalRewards);
        ContestManager(contestManagerContract).fundContest(0);
        // address x = Pot(contest);
        console.log(ERC20Mock(weth).balanceOf(contest));

        vm.stopPrank();
        vm.startPrank(player1);
        Pot(contest).claimCut();
        vm.stopPrank();
        vm.startPrank(player2);
        Pot(contest).claimCut();
        vm.stopPrank();

        address[] memory contests1 = ContestManager(contestManagerContract)
            .getContests();
        uint256 length = contests1.length;
        assertEq(length, 1);
        uint256 length2 = contests1.length;

        vm.warp(block.timestamp + 91 days);
        vm.startPrank(manager);
        ContestManager(contestManagerContract).closeContest(contest);
        ContestManager(contestManagerContract).closeContest(contest);
        vm.stopPrank();
        assertEq(length2, 1);
    }*/
}
