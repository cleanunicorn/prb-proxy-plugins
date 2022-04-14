// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import {PRBProxy} from "@prb/proxy/PRBProxy.sol";
import {PRBProxyPlugins} from "../../PRBProxyPlugins.sol";

import {ERC1155PresetMinterPauser} from "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {ERC1155ReceiverPlugin} from "./ERC1155ReceiverPlugin.sol";

contract ERC1155ReceiverPluginTest is DSTest, ERC1155Holder {
    PRBProxy private proxy;
    PRBProxyPlugins private proxyWithPlugins;

    ERC1155PresetMinterPauser private token;
    uint256 private tokenId = 1;
    uint256 private tokenAmount = 10;

    ERC1155ReceiverPlugin private receiverPlugin;

    function setUp() public {
        // Deploy vanilla proxy
        proxy = new PRBProxy();

        // Deploy proxy with plugin support
        proxyWithPlugins = new PRBProxyPlugins();

        // Deploy token
        token = new ERC1155PresetMinterPauser("ipfs://something/");
        token.mint(address(this), tokenId, tokenAmount, bytes(""));

        // Deploy receiver plugin
        receiverPlugin = new ERC1155ReceiverPlugin();
    }

    function test_deploy() public {
        assertTrue(address(proxy) != address(0));
        assertTrue(address(proxyWithPlugins) != address(0));
    }

    function testFail_proxyCantReceive_ERC1155Token() public {
        // Transfer fails because it does not implement ERC-1155 Token Receiver as specified in EIP-1155
        // https://eips.ethereum.org/EIPS/eip-1155#erc-1155-token-receiver
        token.safeTransferFrom(
            address(this),
            address(proxy),
            tokenId,
            tokenAmount,
            bytes("")
        );
    }

    function test_proxyWithPluginsCanReceive_ERC1155Token() public {
        // Do some magic to make the proxy receive the token
        proxyWithPlugins.install(address(receiverPlugin));

        // Transfer does not fail because it implements ERC-1155 Token Receiver as specified in EIP-1155
        // https://eips.ethereum.org/EIPS/eip-1155#erc-1155-token-receiver
        token.safeTransferFrom(
            address(this),
            address(proxyWithPlugins),
            tokenId,
            tokenAmount,
            bytes("")
        );
    }
}
