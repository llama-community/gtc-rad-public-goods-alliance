// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface IRadicleToken {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function DECIMALS() external view returns (uint8);

    function DELEGATION_TYPEHASH() external view returns (bytes32);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function NAME() external view returns (string memory);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function SYMBOL() external view returns (string memory);

    function allowance(address account, address spender) external view returns (uint256);

    function approve(address spender, uint256 rawAmount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 rawAmount) external;

    function checkpoints(address, uint32) external view returns (uint32 fromBlock, uint96 votes);

    function decimals() external pure returns (uint8);

    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function delegates(address) external view returns (address);

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

    function name() external pure returns (string memory);

    function nonces(address) external view returns (uint256);

    function numCheckpoints(address) external view returns (uint32);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function symbol() external pure returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address dst, uint256 rawAmount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool);
}
