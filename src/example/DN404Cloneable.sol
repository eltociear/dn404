// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../DN404.sol";
import "../DN404Mirror.sol";
import {Ownable} from "../../lib/solady/src/auth/Ownable.sol";
import {LibString} from "../../lib/solady/src/utils/LibString.sol";
import {SafeTransferLib} from "../../lib/solady/src/utils/SafeTransferLib.sol";
import {Clone} from "../../lib/solady/src/utils/Clone.sol";

interface IGasliteDrop {
    function airdropERC20(
        address _token,
        address[] calldata _addresses,
        uint256[] calldata _amounts,
        uint256 _totalAmount
    ) external;
}

contract DN404Cloneable is DN404, Ownable, Clone {
    string private _name;
    string private _sym;
    string private _baseURI;
    bool private initialized = true;

    struct Allocations {
        uint80 liquidityAllocation;
        uint80 teamAllocation;
        uint80 airdropAllocation;
    }

    address private constant _GASLITE_DROP = 0x09350F89e2D7B6e96bA730783c2d76137B045FEF;

    function initialize(
        string calldata name_,
        string calldata sym_,
        Allocations calldata allocations,
        uint96 initialTokenSupply,
        uint256 liquidityLockInSeconds,
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external payable {
        if (initialized) revert();

        _name = name_;
        _sym = sym_;

        _initializeOwner(tx.origin);

        address mirror = address(new DN404Mirror(msg.sender));

        uint256 teamAllocation = allocations.teamAllocation;
        _initializeDN404(uint96(teamAllocation), tx.origin, mirror);
        initialized = true;

        uint256 airdropAllocation = allocations.airdropAllocation;

        if (addresses.length > 0) {
            _mint(address(this), airdropAllocation);
            _approve(address(this), _GASLITE_DROP, airdropAllocation);
            IGasliteDrop(_GASLITE_DROP).airdropERC20(
                address(this), addresses, amounts, airdropAllocation
            );
        }

        uint256 liquidityAllocation = allocations.liquidityAllocation;

        if (liquidityAllocation + teamAllocation + airdropAllocation != initialTokenSupply) {
            revert();
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _sym;
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return bytes(_baseURI).length != 0
            ? string(abi.encodePacked(_baseURI, LibString.toString(tokenId)))
            : "";
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }
}
