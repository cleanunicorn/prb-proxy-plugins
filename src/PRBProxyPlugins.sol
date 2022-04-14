// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
import {PRBProxy} from "@prb/proxy/PRBProxy.sol";

import {IPRBProxyPlugin} from "./IPRBProxyPlugin.sol";

error PRBProxyPlugin__ExecutionReverted();
error PRBProxyPlugin__MethodNotFound();

contract PRBProxyPlugins is PRBProxy {
    // List of methods supported by the proxy
    mapping(bytes4 => address) public installedMethods;

    // Install a plugin
    function install(address plugin_) public {
        // List methods
        bytes4[] memory methodsToInstall = IPRBProxyPlugin(plugin_).methods();

        // Add signatures to fallback method list
        for (uint256 i = 0; i < methodsToInstall.length; i++) {
            installedMethods[methodsToInstall[i]] = plugin_;
        }
    }

    // Uninstall a plugin
    function uninstall(address plugin_) public {
        // List methods
        bytes4[] memory methodsToInstall = IPRBProxyPlugin(plugin_).methods();

        // Add signatures to fallback method list
        for (uint256 i = 0; i < methodsToInstall.length; i++) {
            installedMethods[methodsToInstall[i]] = address(0);
        }
    }

    // prettier-ignore
    fallback(bytes calldata data) external payable returns (bytes memory response) {
        // Check function signature in fallback method list
        address implementation = installedMethods[msg.sig];
        if (implementation == address(0)) {
            // Exit if method is not found
            revert PRBProxyPlugin__MethodNotFound();
        }

        // Reserve some gas to ensure that the function has enough to finish the execution
        uint256 stipend = gasleft() - minGasReserve;

        // Call fallback method
        bool success;
        // solhint-disable-next-line avoid-low-level-calls
        (success, response) = implementation.delegatecall{gas: stipend}(data);

        // Check if the call was successful or not
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxyPlugin__ExecutionReverted();
            }
        }
    }
}
