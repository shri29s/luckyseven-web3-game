// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {LuckySeven} from "../src/LuckySeven.sol";

contract LuckySevenScript is Script {
    LuckySeven public counter;
    function setUp() public {
    }

    function run() public {
        vm.startBroadcast();
        counter = new LuckySeven{value: 100 ether}();
        console.log("Contract address: ", address(counter));
        vm.stopBroadcast();
    }
}
