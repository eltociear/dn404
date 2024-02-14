// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./utils/SoladyTest.sol";
import {DNFactory} from "../src/DNFactory.sol";

contract DNFactoryTest is SoladyTest {
    DNFactory factory;
    address alice = address(111);
    address bob = address(42069);

    address[] addresses;
    uint256[] amounts;

    function setUp() public {
        vm.prank(alice);
        factory = new DNFactory();
    }

    function testDeploy() public {
        addresses.push(bob);
        amounts.push(1);
        DNFactory.Allocations memory allocations = DNFactory.Allocations(100e18, 100e18, 100e18);

        factory.deployDN{value: 200 ether}(
            "DN404",
            "DN",
            allocations,
            300e18,
            60,
            addresses,
            amounts
        );
    }

    // function testName() public {
    //     assertEq(factory.name(), "DN404");
    // }

    // function testSymbol() public {
    //     assertEq(factory.symbol(), "DN");
    // }

    // function testSetBaseURI() public {
    //     vm.prank(alice);
    //     factory.setBaseURI("https://example.com/");
    //     assertEq(factory.tokenURI(1), "https://example.com/1");
    // }

    // function testWithdraw() public {
    //     payable(address(factory)).transfer(1 ether);
    //     assertEq(address(factory).balance, 1 ether);
    //     vm.prank(alice);
    //     factory.withdraw();
    //     assertEq(address(factory).balance, 0);
    //     assertEq(alice.balance, 1 ether);
    // }
}
