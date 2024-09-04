// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20, IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Pot is Ownable(msg.sender) {
    error Pot__RewardNotFound();
    error Pot__InsufficientFunds();
    error Pot__StillOpenForClaim();

    address[] private i_players;
    uint256[] private i_rewards;
    address[] private claimants;
    uint256 private immutable i_totalRewards;
    uint256 private immutable i_deployedAt;
    IERC20 private immutable i_token;
    mapping(address => uint256) private playersToRewards;
    uint256 private remainingRewards;
    uint256 private constant managerCutPercent = 10;

    constructor(
        address[] memory players,
        uint256[] memory rewards,
        IERC20 token,
        uint256 totalRewards
    ) {
        i_players = players;
        i_rewards = rewards;
        i_token = token;
        i_totalRewards = totalRewards;
        remainingRewards = totalRewards;
        i_deployedAt = block.timestamp;

        // i_token.transfer(address(this), i_totalRewards);

        for (uint256 i = 0; i < i_players.length; i++) {
            playersToRewards[i_players[i]] = i_rewards[i];
        }
    }

    function claimCut() public {
        address player = msg.sender;
        uint256 reward = playersToRewards[player];
        if (reward <= 0) {
            revert Pot__RewardNotFound();
        }
        playersToRewards[player] = 0;
        remainingRewards -= reward;
        claimants.push(player);
        _transferReward(player, reward);
    }

    /*  function closePot() external onlyOwner {
        if (block.timestamp - i_deployedAt < 90 days) {
            revert Pot__StillOpenForClaim();
        }
        if (remainingRewards > 0) {
            uint256 managerCut = remainingRewards / managerCutPercent;
            i_token.transfer(msg.sender, managerCut);

            uint256 claimantCut = (remainingRewards - managerCut) /
                i_players.length;
            for (uint256 i = 0; i < claimants.length; i++) {
                _transferReward(claimants[i], claimantCut);
            }
        }
    }*/
    //+++++
    function closePot() external onlyOwner {
        // Ensure that the function can only be called after the 90-day period has elapsed
        if (block.timestamp - i_deployedAt < 90 days) {
            revert Pot__StillOpenForClaim();
        }

        // Check if there are any remaining rewards to distribute
        if (remainingRewards > 0) {
            // ++++  Calculate the manager's cut (10% of remaining rewards)
            uint256 managerCut = (remainingRewards * 10) / 100;

            // Transfer the manager's cut to the manager (msg.sender)
            i_token.transfer(msg.sender, managerCut);

            // Calculate the amount to be distributed among the claimants
            uint256 remainingAfterManagerCut = remainingRewards - managerCut;

            // Ensure there are claimants before attempting to distribute rewards
            if (claimants.length > 0) {
                //++++  Calculate the amount each claimant should receive
                uint256 claimantCut = remainingAfterManagerCut /
                    claimants.length;

                // Distribute the claimant's share to each claimant
                for (uint256 i = 0; i < claimants.length; i++) {
                    _transferReward(claimants[i], claimantCut);
                }
            }

            // After distribution, update the remaining rewards to 0
            remainingRewards = 0;
        }
    }

    function _transferReward(address player, uint256 reward) internal {
        i_token.transfer(player, reward);
    }

    function getToken() public view returns (IERC20) {
        return i_token;
    }

    function checkCut(address player) public view returns (uint256) {
        return playersToRewards[player];
    }

    function getRemainingRewards() public view returns (uint256) {
        return remainingRewards;
    }
}
