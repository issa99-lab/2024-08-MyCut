// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Pot} from "./Pot.sol";
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {ERC20, IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ContestManager is Ownable {
    address[] public contests;
    mapping(address => uint256) public contestToTotalRewards;

    //uint256 balance;
    error ContestManager__InsufficientFunds();

    constructor() Ownable(msg.sender) {}

    function createContest(
        address[] memory players,
        uint256[] memory rewards,
        IERC20 token,
        uint256 totalRewards
    ) public onlyOwner returns (address) {
        // Create a new Pot contract
        Pot pot = new Pot(players, rewards, token, totalRewards);
        contests.push(address(pot));
        contestToTotalRewards[address(pot)] = totalRewards;
        return address(pot);
    }

    function fundContest(uint256 index) public onlyOwner {
        Pot pot = Pot(contests[index]);
        IERC20 token = pot.getToken();
        uint256 totalRewards = contestToTotalRewards[address(pot)];

        // balance = token.balanceOf(msg.sender);

        if (token.balanceOf(msg.sender) < totalRewards) {
            revert ContestManager__InsufficientFunds();
        }

        token.transferFrom(msg.sender, address(pot), totalRewards);
    }

    function getContests() public view returns (address[] memory) {
        return contests;
    }

    function getContestTotalRewards(
        address contest
    ) public view returns (uint256) {
        return contestToTotalRewards[contest];
    }

    function getContestRemainingRewards(
        address contest
    ) public view returns (uint256) {
        Pot pot = Pot(contest);
        return pot.getRemainingRewards();
    }

    //+++
    function closeContest(address contest) public onlyOwner {
        _closeContest(contest);
        removeAddress(contest);
    }

    //+++
    function removeAddress(address toRemove) internal {
        uint256 length = contests.length;
        for (uint256 i = 0; i < length; i++) {
            if (contests[i] == toRemove) {
                // Move the last element into the place to delete
                contests[i] = contests[length - 1];
                // Remove the last element
                contests.pop();
                return;
            }
        }
        // If the address is not found, you may want to handle this case.
        // E.g., revert with an error or do nothing.
    }

    function _closeContest(address contest) internal {
        Pot pot = Pot(contest);
        pot.closePot();
    }
}
