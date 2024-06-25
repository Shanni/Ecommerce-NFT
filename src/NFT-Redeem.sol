// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Ecommerce is ERC1155, AccessControl, ERC1155Pausable, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    uint256 private constant PRICE = 0.003 ether;
    uint256 private pendingBalance;

    event Minted(address indexed account, uint256 indexed id, uint256 amount);

    error InsufficientEther(uint256 required, uint256 provided);
    error ExceedsMaxSupply(uint256 requested, uint256 available);

    constructor(address defaultAdmin) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function grantManagerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MANAGER_ROLE, account);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public payable {
        uint256 totalCost = amount * PRICE;

        if (msg.value < totalCost) {
            revert InsufficientEther({required: totalCost, provided: msg.value});
        }

        _mint(account, id, amount, data);
        emit Minted(account, id, amount);

        pendingBalance += msg.value;
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Checker
        require(pendingBalance > 0, "No funds to withdraw");

        uint256 totalAmount = pendingBalance;

        // Set state to 0
        pendingBalance = 0;

        // Transaction
        (bool success1,) = payable(msg.sender).call{value: totalAmount}("");

        require(success1, "Transfer failed");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
        _mintBatch(to, ids, amounts, data);
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // This function is used to add supply 
    function addSupply(uint256[] memory ids, uint256[] memory values) public onlyRole(MANAGER_ROLE){
        _update(address(0), msg.sender, ids, values);
    }

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
