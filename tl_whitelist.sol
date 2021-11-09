// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";

contract tlWhitelist is Ownable {
    /**
     * Using a mapping allows us to easily lookup
     * addresses for whitelist validation
     */
    mapping(address => uint256) public whitelist;

    /**
     * Maintain an array of addresses due to Solidity's
     * lack of lists
     */
    address[] public keys;

    constructor() {
        // Our initial whitelist entries
        keys = [
            0xF452C6148FD24e83bbAD816835845063a8f56042,
            0x40BB38f6f41E45D2060CA33aa1e2fE0504A273D0
        ];

        populateMapping();
    }

    function populateMapping() internal {
        for (uint256 i = 0; i < keys.length; i++) {
            whitelist[keys[i]] = i;
        }
    }

    /**
     * Allows the owner of the contract to dynamically
     * add additional whitelist entries
     */
    function add(address addr) public onlyOwner {
        if (whitelist[addr] == 0) {
            keys.push(addr);
            whitelist[addr] = keys.length - 1;
        }
    }

    /**
     * Allows the owner of the contract to remove whitelist entries
     */
    function remove(uint256 addrKey) public onlyOwner {
        address addr = keys[addrKey];
        delete keys[addrKey];
        whitelist[addr] = 0;
    }

    /**
     * As we cannot return a list of mappings, we can use the key
     * array to interate through each of the values in the mapping
     */
    function total() public view returns (uint256) {
        return keys.length;
    }
}
