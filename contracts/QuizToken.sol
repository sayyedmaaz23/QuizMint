// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuizToken is ERC20, Ownable {
    uint256 public constant ENTRY_FEE = 1 * 10 ** 18; // 1 token (with decimals)
    uint256 public constant MAX_REWARD = 3 * 10 ** 18; // 3 tokens max

    mapping(address => bool) public inQuiz; // Tracks active players

    constructor() ERC20("QuizToken", "QZT") Ownable(msg.sender) {
        _mint(msg.sender, 100 * 10 ** 18); // initial supply for testing/admin
    }

    // Player pays 1 token to enter quiz
    function enterQuiz() external {
        require(
            balanceOf(msg.sender) >= ENTRY_FEE,
            "Insufficient tokens to enter"
        );
        require(!inQuiz[msg.sender], "Already in a quiz");

        _transfer(msg.sender, owner(), ENTRY_FEE); // send entry fee to admin/game pool
        inQuiz[msg.sender] = true;
    }

    // Owner (backend or admin) rewards player based on score
    function rewardPlayer(
        address player,
        uint8 correctAnswers,
        uint8 totalQuestions
    ) external onlyOwner {
        require(inQuiz[player], "Player not in quiz");
        require(totalQuestions > 0, "Invalid quiz data");
        require(correctAnswers <= totalQuestions, "Invalid answer count");

        uint256 reward = 0;

        uint8 threshold = uint8((totalQuestions * 80 + 99) / 100); // avoids rounding errors

        if (correctAnswers >= threshold && correctAnswers < totalQuestions) {
            reward = 1 * 10 ** 18; // 1 token for 80% or more correct
        } else if (correctAnswers == totalQuestions) {
            reward = MAX_REWARD; // 3 tokens for perfect score
        }

        if (reward > 0) {
            _mint(player, reward);
        }

        inQuiz[player] = false; // mark quiz as completed
    }

    // Admin can mint tokens for liquidity or testing
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
