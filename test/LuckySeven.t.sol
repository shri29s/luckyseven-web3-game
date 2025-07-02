// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {LuckySeven} from "../src/LuckySeven.sol";

contract CounterTest is Test {
    LuckySeven public game;
    uint initialBalance = 100 ether;

    function setUp() public {
        game = new LuckySeven{value: initialBalance}();
        
    }

    function test_GetBalance() view public {
        assertEq(game.getBalance(), initialBalance);
    }

    function test_WithdrawEthers() public {
        vm.expectRevert("You are not authenticated");
        vm.prank(address(10));
        game.withdrawEthers();
    }

    function test_Play1() public {
        vm.expectRevert("Service is unavailable");
        game.play{value: 200 ether}(LuckySeven.Choice(2));
    }

    function test_Play2() public {
        vm.expectRevert("Insufficient funds");
        game.play{value: 0.001 ether}(LuckySeven.Choice(2));
    }
}
