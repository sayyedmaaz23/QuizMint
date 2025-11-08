// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuizToken is ERC20, Ownable {
    uint256 public constant TOKENS_PER_ETH = 100 * 10**18; // 1 ETH = 100 QZT
    uint256 public constant ENTRY_FEE = 1 * 10**18;        // 1 QZT per quiz
    mapping(address => bool) public inQuiz;

    constructor() ERC20("QuizToken", "QZT") Ownable(msg.sender) {}

    /* ---------------- BUY TOKENS ---------------- */
    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 amount = (msg.value * TOKENS_PER_ETH) / 1 ether;
        _mint(msg.sender, amount);
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /* ---------------- ENTER OR LEAVE QUIZ ---------------- */
    function toggleQuiz() external {
        if (inQuiz[msg.sender]) {
            // leave
            inQuiz[msg.sender] = false;
        } else {
            // enter
            require(balanceOf(msg.sender) >= ENTRY_FEE, "Not enough tokens");
            // burn entry fee instead of transferring to owner
            _burn(msg.sender, ENTRY_FEE);
            inQuiz[msg.sender] = true;
        }
    }

    /* ---------------- REWARD PLAYER ---------------- */
    function rewardPlayer(uint8 correct, uint8 total) external {
        require(inQuiz[msg.sender], "Not in quiz");
        require(total > 0, "Invalid total");

        uint8 threshold =5; // 80% or more = reward

        if (correct >= threshold && correct < total) {
            _mint(msg.sender, 1 * 10**18); // 1 QZT for ≥80%
        } else if (correct == total) {
            _mint(msg.sender, 3 * 10**18); // 3 QZT for perfect score
        }

        inQuiz[msg.sender] = false;
    }
}
