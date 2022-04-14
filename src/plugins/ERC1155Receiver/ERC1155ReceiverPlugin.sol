// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {IPRBProxyPlugin} from "../../IPRBProxyPlugin.sol";

contract ERC1155ReceiverPlugin is ERC1155Holder, IPRBProxyPlugin {
    function methods()
        public
        pure
        override(IPRBProxyPlugin)
        returns (bytes4[] memory)
    {
        bytes4[] memory supportedMethods = new bytes4[](2);
        supportedMethods[0] = this.onERC1155Received.selector;
        supportedMethods[1] = this.onERC1155BatchReceived.selector;

        return supportedMethods;
    }
}
