// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// testing libraries
import "@ds/test.sol";
import "@std/console.sol";
import {stdCheats} from "@std/stdlib.sol";
import {Vm} from "@std/Vm.sol";
import {DSTestPlus} from "@solmate/test/utils/DSTestPlus.sol";

// contract dependencies
import {IGitcoinGovernor} from "../external/IGitcoinGovernor.sol";
import {IGitcoinTimelock} from "../external/IGitcoinTimelock.sol";
import {IGitcoinToken} from "../external/IGitcoinToken.sol";
import {IRadicleGovernor} from "../external/IRadicleGovernor.sol";
import {IRadicleTimelock} from "../external/IRadicleTimelock.sol";
import {IRadicleToken} from "../external/IRadicleToken.sol";

import {GtcRadGrant} from "../GtcRadGrant.sol";

contract GtcRadGrantTest is DSTestPlus, stdCheats {
    Vm private vm = Vm(HEVM_ADDRESS);

    IGitcoinGovernor public constant GITCOIN_GOVERNOR = IGitcoinGovernor(0xDbD27635A534A3d3169Ef0498beB56Fb9c937489);
    IGitcoinTimelock public constant GITCOIN_TIMELOCK =
        IGitcoinTimelock(payable(0x57a8865cfB1eCEf7253c27da6B4BC3dAEE5Be518));
    IGitcoinToken public constant GITCOIN_TOKEN = IGitcoinToken(0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F);
    IRadicleGovernor public constant RADICLE_GOVERNOR = IRadicleGovernor(0x690e775361AD66D1c4A25d89da9fCd639F5198eD);
    IRadicleTimelock public constant RADICLE_TIMELOCK =
        IRadicleTimelock(payable(0x8dA8f82d2BbDd896822de723F55D6EdF416130ba));
    IRadicleToken public constant RADICLE_TOKEN = IRadicleToken(0x31c8EAcBFFdD875c74b94b077895Bd78CF1E64A3);

    address public constant LLAMA_TREASURY = 0xA519a7cE7B24333055781133B13532AEabfAC81b;
    address public constant GTC_MULTISIG = 0xBD8d617Ac53c5Efc5fBDBb51d445f7A2350D4940;
    address public constant RAD_MULTISIG = 0x93F80a67FdFDF9DaF1aee5276Db95c8761cc8561;

    address public constant MOCK_RADICLE_PROPOSER = 0x464D78a5C97A2E2E9839C353ee9B6d4204c90B0b;
    address public constant MOCK_GITCOIN_PROPOSER = 0x894Aa5F1E45454677A8560ddE3B45Cb5C427Ef92;

    string public constant DESCRIPTION = "GTC <> RAD Public Goods Alliance";

    // To be change-d later
    uint256 public constant GTC_AMOUNT = 500000e18;
    uint256 public constant RAD_AMOUNT = 885990e18;
    uint256 public constant LLAMA_GTC_PAYMENT_AMOUNT = 6945e18;
    uint256 public constant LLAMA_RAD_PAYMENT_AMOUNT = 11765e18;
    // To be change-d later

    GtcRadGrant public gtcRadGrant;

    address[] private radWhales = [
        0xEA95cfB5Dd624F43775b372db0ED2D8d0073E91C,
        0x464D78a5C97A2E2E9839C353ee9B6d4204c90B0b
    ];

    address[] private gtcWhales = [
        0xc2E2B715d9e302947Ec7e312fd2384b5a1296099,
        0x34aA3F359A9D614239015126635CE7732c18fDF3
    ];

    function setUp() public {
        gtcRadGrant = new GtcRadGrant(GTC_AMOUNT, RAD_AMOUNT);
        vm.label(address(gtcRadGrant), "GtcRadGrant");

        vm.label(address(GITCOIN_GOVERNOR), "GITCOIN_GOVERNOR");
        vm.label(address(GITCOIN_TIMELOCK), "GITCOIN_TIMELOCK");
        vm.label(address(GITCOIN_TOKEN), "GITCOIN_TOKEN");
        vm.label(address(RADICLE_GOVERNOR), "RADICLE_GOVERNOR");
        vm.label(address(RADICLE_TIMELOCK), "RADICLE_TIMELOCK");
        vm.label(address(RADICLE_TOKEN), "RADICLE_TOKEN");
        vm.label(MOCK_RADICLE_PROPOSER, "MOCK_RADICLE_PROPOSER");
        vm.label(MOCK_GITCOIN_PROPOSER, "MOCK_GITCOIN_PROPOSER");
        vm.label(LLAMA_TREASURY, "LLAMA_TREASURY");
        vm.label(GTC_MULTISIG, "GTC_MULTISIG");
        vm.label(RAD_MULTISIG, "RAD_MULTISIG");
    }

    /******************
     *   Test Cases   *
     ******************/

    function testRadicleProposal1() public {
        _runRadicleProposal1();
        assertEq(RADICLE_TOKEN.allowance(address(RADICLE_TIMELOCK), address(gtcRadGrant)), RAD_AMOUNT);
    }

    function _runRadicleProposal1() private {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        string[] memory signatures = new string[](1);
        bytes[] memory calldatas = new bytes[](1);

        // Approve the GTC <> RAD Public Goods Alliance grant contract to transfer pre-defined amount of RAD tokens
        targets[0] = address(RADICLE_TOKEN);
        values[0] = uint256(0);
        signatures[0] = "approve(address,uint256)";
        calldatas[0] = abi.encode(address(gtcRadGrant), RAD_AMOUNT);

        uint256 proposalID = _radicleCreateProposal(targets, values, signatures, calldatas, DESCRIPTION);
        _radicleRunGovProcess(proposalID);
    }

    function testGitcoinProposal() public {
        _runRadicleProposal1();

        _runGitcoinProposal();
    }

    function _runGitcoinProposal() private {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        string[] memory signatures = new string[](4);
        bytes[] memory calldatas = new bytes[](4);

        // Approve the GTC <> RAD Public Goods Alliance grant contract to transfer pre-defined amount of GTC tokens
        targets[0] = address(GITCOIN_TOKEN);
        values[0] = uint256(0);
        signatures[0] = "approve(address,uint256)";
        calldatas[0] = abi.encode(address(gtcRadGrant), GTC_AMOUNT);

        // Execute the GTC <> RAD Public Goods Alliance grant
        targets[1] = address(gtcRadGrant);
        values[1] = uint256(0);
        signatures[1] = "grant()";
        bytes memory emptyBytes;
        calldatas[1] = emptyBytes;

        // Delegate the received RAD tokens in GTC Treasury to the GTC Multisig
        targets[2] = address(RADICLE_TOKEN);
        values[2] = uint256(0);
        signatures[2] = "delegate(address)";
        calldatas[2] = abi.encode(GTC_MULTISIG);

        // Payment to Llama Treasury
        targets[3] = address(GITCOIN_TOKEN);
        values[3] = uint256(0);
        signatures[3] = "transfer(address,uint256)";
        calldatas[3] = abi.encode(LLAMA_TREASURY, LLAMA_GTC_PAYMENT_AMOUNT);

        uint256 proposalID = _gitcoinCreateProposal(targets, values, signatures, calldatas, DESCRIPTION);
        _gitcoinRunGovProcess(proposalID);
    }

    /***************************
     *   Radicle Gov Process   *
     ***************************/

    function _radicleCreateProposal(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private returns (uint256 proposalID) {
        // Proposer that has > 1M RAD votes
        vm.prank(MOCK_RADICLE_PROPOSER);
        proposalID = RADICLE_GOVERNOR.propose(targets, values, signatures, calldatas, description);
    }

    function _radicleVoteOnProposal(uint256 proposalID) private {
        (, , uint256 startBlock, , , , , ) = RADICLE_GOVERNOR.proposals(proposalID);
        // Skipping Proposal delay of 1 block
        vm.roll(startBlock + 1);
        // Hitting quorum of > 4M RAD votes
        for (uint256 i; i < radWhales.length; i++) {
            vm.prank(radWhales[i]);
            RADICLE_GOVERNOR.castVote(proposalID, true);
        }
    }

    function _radicleSkipVotingPeriod(uint256 proposalID) private {
        (, , , uint256 endBlock, , , , ) = RADICLE_GOVERNOR.proposals(proposalID);
        // Skipping Voting period of 3 days worth of blocks
        vm.roll(endBlock + 1);
    }

    function _radicleQueueProposal(uint256 proposalID) private {
        RADICLE_GOVERNOR.queue(proposalID);
    }

    function _radicleSkipQueuePeriod(uint256 proposalID) private {
        (, uint256 eta, , , , , , ) = RADICLE_GOVERNOR.proposals(proposalID);
        // Skipping Queue period of 2 days
        vm.warp(eta);
    }

    function _radicleExecuteProposal(uint256 proposalID) private {
        RADICLE_GOVERNOR.execute(proposalID);
    }

    function _radicleRunGovProcess(uint256 proposalID) private {
        _radicleVoteOnProposal(proposalID);
        _radicleSkipVotingPeriod(proposalID);
        _radicleQueueProposal(proposalID);
        _radicleSkipQueuePeriod(proposalID);
        _radicleExecuteProposal(proposalID);
    }

    /***************************
     *   Gitcoin Gov Process   *
     ***************************/

    function _gitcoinCreateProposal(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private returns (uint256 proposalID) {
        // Proposer that has > 1M GTC votes
        vm.prank(MOCK_GITCOIN_PROPOSER);
        proposalID = GITCOIN_GOVERNOR.propose(targets, values, signatures, calldatas, description);
    }

    function _gitcoinVoteOnProposal(uint256 proposalID) private {
        (, , , uint256 startBlock, , , , , ) = GITCOIN_GOVERNOR.proposals(proposalID);
        // Skipping Proposal delay of 2 days worth of blocks
        vm.roll(startBlock + 1);
        // Hitting quorum of > 2.5M GTC votes
        for (uint256 i; i < gtcWhales.length; i++) {
            vm.prank(gtcWhales[i]);
            GITCOIN_GOVERNOR.castVote(proposalID, true);
        }
    }

    function _gitcoinSkipVotingPeriod(uint256 proposalID) private {
        (, , , , uint256 endBlock, , , , ) = GITCOIN_GOVERNOR.proposals(proposalID);
        // Skipping Voting period of 7 days worth of blocks
        vm.roll(endBlock + 1);
    }

    function _gitcoinQueueProposal(uint256 proposalID) private {
        GITCOIN_GOVERNOR.queue(proposalID);
    }

    function _gitcoinSkipQueuePeriod(uint256 proposalID) private {
        (, , uint256 eta, , , , , , ) = GITCOIN_GOVERNOR.proposals(proposalID);
        // Skipping Queue period of 2 days
        vm.warp(eta);
    }

    function _gitcoinExecuteProposal(uint256 proposalID) private {
        GITCOIN_GOVERNOR.execute(proposalID);
    }

    function _gitcoinRunGovProcess(uint256 proposalID) private {
        _gitcoinVoteOnProposal(proposalID);
        _gitcoinSkipVotingPeriod(proposalID);
        _gitcoinQueueProposal(proposalID);
        _gitcoinSkipQueuePeriod(proposalID);
        _gitcoinExecuteProposal(proposalID);
    }
}
