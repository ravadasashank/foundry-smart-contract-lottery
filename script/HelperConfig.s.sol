//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstatnts {
    /* VRF MOCK VALUES */
    uint96 public Mock_BASE_FEE = 0.25 ether;
    uint96 public Mock_GAS_PRICE_LINK = 1e9; // 0.000000001 LINK per gas
    //LINK /ETH PRICE = 0.004 ETH per LINK
    int256 public Mock_WEI_PER_UNIT_LINK = 4e15;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is Script {

    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[11155111] = getSepoliaConfig();
        networkConfigs[31337] = getOrCreateAnvilEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        }else if(chainId == 31337) {
            getOrCreateAnvilEthConfig();
        }
        else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns(NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval: 30, //30 seconds
            vrfCoordinator: 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61,
            gasLane: 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be,
            subscriptionId: 0, 
            callbackGasLimit: 500000, // 500,000 gas
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
       //check if we have a config already
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        //Deploy mocks and such
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
            0.25 ether,
            1e9,
            4e15
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            //doesn't matter for mocks
            gasLane: 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            link: address(linkToken)
        });
        return localNetworkConfig;
    }
}