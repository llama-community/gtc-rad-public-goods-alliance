// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface IGitcoinTimelock {
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    event NewAdmin(address indexed newAdmin);
    event NewDelay(uint256 indexed newDelay);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    event ValueReceived(address user, uint256 amount);

    function GRACE_PERIOD() external view returns (uint256);

    function MAXIMUM_DELAY() external view returns (uint256);

    function MINIMUM_DELAY() external view returns (uint256);

    function acceptAdmin() external;

    function admin() external view returns (address);

    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external;

    function delay() external view returns (uint256);

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external payable returns (bytes memory);

    function pendingAdmin() external view returns (address);

    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) external returns (bytes32);

    function queuedTransactions(bytes32) external view returns (bool);

    function setDelay(uint256 delay_) external;

    function setPendingAdmin(address pendingAdmin_) external;

    receive() external payable;
}
