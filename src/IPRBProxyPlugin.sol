// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IPRBProxyPlugin {
    function methods() external view returns (bytes4[] memory);
}
