// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20, IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Pot is Ownable(msg.sender) {
    error Pot__RewardNotFound();
    error Pot__InsufficientFunds();
    error Pot__StillOpenForClaim();

    address[] private i_players; //people
    uint256[] private i_rewards; //number
    address[] private claimants; //people that are eligible for rewards 90 days tops
    uint256 private immutable i_totalRewards; //no of rewards
    uint256 private immutable i_deployedAt; // time deployed
    IERC20 private immutable i_token;
    mapping(address => uint256) private playersToRewards; //players to no of rewards?
    uint256 private remainingRewards; //after the time has elapsed?
    uint256 private constant managerCutPercent = 10; //remainder (90%) distributed to claimants. can non-claimants ask for rewards?

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
        //i_players.length can be a number outside to save on gas
        for (uint256 i = 0; i < i_players.length; i++) {
            playersToRewards[i_players[i]] = i_rewards[i];
        }
    }

    /*@audit anyone can call the function? Yes 
    They wont receive anything since they got nothing (checks)

     */
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

    /*@audit manager gets wrong rewards calculation, not 10%*/
    function closePot() external onlyOwner {
        if (block.timestamp - i_deployedAt < 90 days) {
            revert Pot__StillOpenForClaim();
        }
        if (remainingRewards > 0) {
            uint256 managerCut = remainingRewards / managerCutPercent;
            /*@ audit uint256 managerCut = (remainingRewards * managerCutPercent) / 100;
             */
            i_token.transfer(msg.sender, managerCut);

            uint256 claimantCut = (remainingRewards - managerCut) /
                i_players.length;
            for (uint256 i = 0; i < claimants.length; i++) {
                _transferReward(claimants[i], claimantCut); //what if 1 of the claimant's fallback's reverts? it'll always revert
            }
            //not updated the remaining rewards to 0 bc ishaisha after distributing
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

    function getOwner() public view returns (address) {
        return Ownable.owner();
    }

    receive() external payable {
        // emit Received(msg.sender, msg.value);
    }
}
