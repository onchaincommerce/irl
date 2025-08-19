// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ClaimVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum Status { None, Pending, Claimed, Refunded }

    struct Claim {
        address sender;
        address token;
        uint128 amount;
        uint40 expiry;
        Status status;
        bytes32 secretHash;
    }

    mapping(bytes32 => Claim) public claims;
    
    event ClaimCreated(
        bytes32 indexed claimId,
        address indexed sender,
        address token,
        uint256 amount,
        uint40 expiry
    );
    
    event Claimed(
        bytes32 indexed claimId,
        address indexed receiver,
        uint256 amount
    );
    
    event Refunded(
        bytes32 indexed claimId,
        address indexed sender,
        uint256 amount
    );

    error ClaimNotFound();
    error ClaimAlreadyProcessed();
    error ClaimExpired();
    error InvalidSecret();

    function deposit(
        bytes32 claimId,
        address token,
        uint256 amount,
        bytes32 secretHash,
        uint40 expiry
    ) external nonReentrant {
        if (claims[claimId].status != Status.None) {
            revert ClaimAlreadyProcessed();
        }
        
        if (expiry <= block.timestamp) {
            revert ClaimExpired();
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        claims[claimId] = Claim({
            sender: msg.sender,
            token: token,
            amount: uint128(amount),
            expiry: expiry,
            status: Status.Pending,
            secretHash: secretHash
        });

        emit ClaimCreated(claimId, msg.sender, token, amount, expiry);
    }

    function claim(
        bytes32 claimId,
        bytes calldata secret,
        address receiver
    ) external nonReentrant {
        Claim storage claimData = claims[claimId];
        
        if (claimData.status == Status.None) {
            revert ClaimNotFound();
        }
        
        if (claimData.status != Status.Pending) {
            revert ClaimAlreadyProcessed();
        }
        
        if (claimData.expiry <= block.timestamp) {
            revert ClaimExpired();
        }

        bytes32 secretHash = keccak256(secret);
        if (secretHash != claimData.secretHash) {
            revert InvalidSecret();
        }

        claimData.status = Status.Claimed;
        IERC20(claimData.token).safeTransfer(receiver, claimData.amount);

        emit Claimed(claimId, receiver, claimData.amount);
    }

    function refund(bytes32 claimId) external nonReentrant {
        Claim storage claimData = claims[claimId];
        
        if (claimData.status == Status.None) {
            revert ClaimNotFound();
        }
        
        if (claimData.status != Status.Pending) {
            revert ClaimAlreadyProcessed();
        }
        
        if (claimData.expiry > block.timestamp) {
            revert ClaimExpired();
        }

        claimData.status = Status.Refunded;
        IERC20(claimData.token).safeTransfer(claimData.sender, claimData.amount);

        emit Refunded(claimId, claimData.sender, claimData.amount);
    }

    function getClaim(bytes32 claimId) external view returns (Claim memory) {
        return claims[claimId];
    }

    function isClaimValid(bytes32 claimId) external view returns (bool) {
        Claim memory claimData = claims[claimId];
        return claimData.status == Status.Pending && claimData.expiry > block.timestamp;
    }
}
