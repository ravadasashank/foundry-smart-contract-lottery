// SPDX-LICENSE-Identifier: MIT
pragma solidity 0.8.19; 
import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns(uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordiantor = helperConfig.getConfig().vrfCoordinator;
        (uint256 subId, )= createSubscription(vrfCoordiantor);
        return (subId, vrfCoordiantor);
    }

    function createSubscription(address vrfCoordinator) public  returns(uint256, address){
        console.log("Creating subscription on chain Id: ",block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol and re-deploy Raffle contract");
        return (subId, vrfCoordinator);
        
    }

    function run() public {}
}

contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 2 ether;

    function fundSubscriptionUsingConfig(uint256 subscriptionId) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordiantor = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address link = helperConfig.getConfig().link;
        fundSubscription(vrfCoordiantor, subscriptionId, link);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {
        console.log("Funding subscription on chain Id: ",block.chainid);
        console.log("Using VRF Coordinator: ", vrfCoordinator);
        console.log("Chain Id: ", block.chainid);
        if(block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            console.log("Funding with LINK token");
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
        console.log("Funded subscription ", subscriptionId);
    }

    function run() public {}
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed)  public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordiantor = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        addConsumer(mostRecentlyDeployed, vrfCoordiantor, subscriptionId);
    }

    function addConsumer(address contractToAddtoVrf, address vrfCoordinator, uint256 subId) public {
        console.log("Adding consumer contarct: ", contractToAddtoVrf);
        console.log("To VRF Coordinator: ", vrfCoordinator);
        console.log("On Chain Id: ", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, contractToAddtoVrf);
        vm.stopBroadcast();
        console.log("Consumer added to subscription ", subId);
    }

    function run() external{
        address mostRecentDeployedRaffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentDeployedRaffle);
    }
}