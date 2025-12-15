# Foundry Smart Contract Lottery

A decentralized, provably fair lottery (raffle) built with Solidity, Foundry, and Chainlink VRF v2.5. Designed as a clean, production-style reference project suitable for both learning and showcasing to recruiters and Web3 teams.

## Overview

Foundry Smart Contract Lottery is a decentralized raffle where users join by paying an entrance fee in ETH, and a random winner is selected at fixed intervals using Chainlink VRF v2.5. The full contract balance is transferred to the winner, and the lottery automatically resets for the next round, enabling continuous, hands-off operation.

The project is built with Solidity ^0.8.19 and the Foundry toolchain (Forge, Cast, Anvil), following modern best practices for testing, scripting, and configuration. It targets both local development (Anvil) and the Sepolia testnet, making it a practical template for real-world deployments.

## Tech Stack

- **Solidity ^0.8.19** for the core smart contracts and business logic.
- **Foundry** (Forge, Cast, Anvil) for compilation, testing, scripting, and local node emulation.
- **Chainlink VRF v2.5** for verifiable, tamper-proof on-chain randomness used in winner selection.

## Features

- **Decentralized and trustless lottery** where all rules are enforced by smart contracts on-chain.
- **Secure randomness powered by Chainlink VRF v2.5**, ensuring provably fair winner selection that cannot be gamed by miners, validators, or participants.
- **Automated winner selection** based on a configurable time interval, enabling a hands-off raffle experience.
- **Comprehensive test suite** using Foundry, including unit and integration tests to validate core logic and edge cases.
- **Modular deployment and interaction scripts** for repeatable operations across local and testnet environments.
- **Support for local and testnet development** with Anvil and Sepolia testnet for end-to-end Web3 workflows.

## Project Structure

```
foundry-smart-contract-lottery/
├── src/                 # Core lottery contracts (e.g., Raffle.sol)
├── script/              # Deployment & interaction scripts
├── test/                # Unit and integration tests
├── lib/                 # External dependencies
├── foundry.toml         # Foundry configuration
├── README.md            # This file
└── .env.example         # Environment variables template
```

- **src/** → Core smart contracts implementing entry, randomness request, and winner payout logic.
- **script/** → Foundry scripts for deployment, configuration, and interaction (e.g., VRF subscription setup, consumer registration, draw execution).
- **test/** → Unit and integration tests covering entry rules, upkeep checks, VRF callbacks, and state resets.
- **lib/** → External dependencies such as Chainlink contracts and Foundry-standard libraries.
- **foundry.toml** → Foundry configuration, including compiler settings, remappings, and default profiles.

## Getting Started

Follow these steps to set up the project locally and run it with Foundry and Anvil.

### Prerequisites

- **Git** for cloning the repository
- **Foundry** (Forge, Cast, Anvil)
- **Node.js** (optional, for additional tooling)

### 1. Clone the Repository

```bash
git clone https://github.com/ravadasashank/foundry-smart-contract-lottery.git
cd foundry-smart-contract-lottery
```

Cloning locally allows you to inspect contracts, scripts, and tests, and to adapt the project for your own deployments.

### 2. Install Foundry

If you do not have Foundry installed, use the official installer:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Foundry provides `forge` for building/testing and `anvil` for running a local Ethereum node.

### 3. Install Dependencies

Use Foundry to pull and update on-chain and library dependencies:

```bash
forge install
forge update
```

This ensures all external packages in `lib/` and remappings in `foundry.toml` are correctly resolved.

### 4. Build and Run Tests

```bash
forge build
forge test
```

`forge build` compiles the contracts with the configured compiler version, and `forge test` executes the test suite to validate core lottery behavior before deployment.

For verbose test output:

```bash
forge test -vv
```

### 5. Run a Local Node with Anvil

```bash
anvil
```

Anvil starts a local Ethereum JSON-RPC node with funded test accounts, ideal for fast iteration and debugging. You can point `forge script` and frontends at the provided RPC URL (typically `http://127.0.0.1:8545`).

### 6. Deploy Using Forge Scripts

In a new terminal (with Anvil still running), deploy with a Foundry script:

```bash
forge script script/DeployRaffle.s.sol \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

`forge script` allows reproducible deployments and post-deploy actions, such as setting up Chainlink VRF configuration, from version-controlled scripts.

**For Sepolia testnet:**

Replace the RPC URL and private key with your testnet values and configure Chainlink VRF v2.5 subscription details as required by the Chainlink documentation.

```bash
forge script script/DeployRaffle.s.sol \
  --rpc-url https://sepolia.infura.io/v3/<YOUR_INFURA_KEY> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

## Usage

Once deployed, users can enter the raffle by calling the `enterRaffle` or equivalent function and sending the required ETH entrance fee. At predefined intervals, the contract triggers a Chainlink VRF request, receives a random word, and selects a winner who receives the full contract balance.

The lottery state is automatically reset after a winner is picked, allowing subsequent rounds without manual intervention. Scripts and tests can be used to simulate multiple rounds and verify behavior under different conditions.

### Example: Entering the Lottery

```solidity
// Assuming you have a deployed Raffle contract at address `raffleAddress`
Raffle raffle = Raffle(raffleAddress);
raffle.enterRaffle{value: entranceFee}();
```

### Example: Checking Lottery State

```solidity
address[] memory players = raffle.getPlayers();
uint256 prizePool = address(raffle).balance;
bool upkeepNeeded = raffle.checkUpkeep("");
```

## Security Notes

- **Uses Chainlink VRF v2.5** for randomness, avoiding insecure sources such as `blockhash`, `block.timestamp`, or predictable pseudo-random mechanisms.
- **Separates randomness request and fulfillment** paths, following Chainlink's recommended request-and-receive pattern to prevent manipulation.
- **Avoids block-based randomness** and miner-influenced values, which are known to be exploitable in lottery-style protocols.
- **Implements proper error handling** and access control for sensitive operations like configuration changes, VRF subscription management, and emergency withdrawals.
- **Encourages careful handling** of private keys and RPC URLs via environment variables or `.env` files rather than hardcoding secrets in scripts.
- **Tested against edge cases** including zero players, failed VRF callbacks, and rapid successive draws.

## Learning Outcomes

This project is intended both as a portfolio piece and a learning playground for modern Solidity and Foundry workflows. Working through it helps solidify several key skills.

- **Writing production-style Solidity contracts**, including NatSpec comments, custom errors, events, and clean state machine design.
- **Using Foundry for testing** (unit, integration, fuzzing), scripting, and automating repetitive deployment and interaction tasks.
- **Integrating Chainlink VRF v2.5** into a live contract, including subscription configuration, consumer registration, and callback handling.
- **Understanding decentralized automation patterns** where time-based checks and external services (e.g., Chainlink) keep the system running without centralized operators.

## Testing

The project includes a comprehensive test suite covering:

- **Unit tests** for individual contract functions (entrance, randomness requests, winner selection).
- **Integration tests** for multi-step workflows (enter → wait → draw → reset).
- **Fuzzing tests** to validate behavior under extreme or random inputs.

Run all tests:

```bash
forge test
```

Run specific test file:

```bash
forge test --match-path test/unit/RaffleTest.t.sol
```

Run with coverage:

```bash
forge coverage
```

## Deployment Checklist

Before deploying to mainnet or a public testnet:

- [ ] Review all contract code and tests
- [ ] Configure Chainlink VRF v2.5 subscription and add contract as consumer
- [ ] Set entrance fee and interval values appropriate for your use case
- [ ] Test deployment scripts on Anvil and Sepolia
- [ ] Verify gas costs and optimize if needed
- [ ] Audit smart contracts (consider professional security audit for production)
- [ ] Set up monitoring and alerting for live deployments

## Environment Variables

Create a `.env` file in the project root with the following variables:

```env
# Local node (Anvil)
RPC_URL_ANVIL=http://127.0.0.1:8545

# Sepolia testnet
RPC_URL_SEPOLIA=https://sepolia.infura.io/v3/<YOUR_INFURA_KEY>

# Private key for deployment (never commit to version control)
PRIVATE_KEY=<YOUR_PRIVATE_KEY>

# Chainlink VRF configuration
VRF_SUBSCRIPTION_ID=<YOUR_SUBSCRIPTION_ID>
VRF_COORDINATOR=0x8103b0a8a00be6ddc3b0ff352c09e6deac4486ff  # Sepolia address
KEYHASH=0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c  # Sepolia
CALLBACK_GAS_LIMIT=2500000
```

Load these in your scripts using:

```solidity
import {stdenv} from "forge-std/StdEnv.sol";

uint256 private key = vm.envUint("PRIVATE_KEY");
string memory rpcUrl = vm.envString("RPC_URL_SEPOLIA");
```

## Useful Foundry Commands

```bash
# Compile contracts
forge build

# Run tests with detailed output
forge test -vv

# Run tests with gas report
forge test --gas-report

# Format code
forge fmt

# Lint with Solhint (if installed)
solhint src/**/*.sol

# Deploy script
forge script script/DeployRaffle.s.sol --broadcast --verify

# Interact with deployed contract
cast call <CONTRACT_ADDRESS> "getPlayers()" --rpc-url <RPC_URL>

# Send transaction
cast send <CONTRACT_ADDRESS> "enterRaffle()" --value 1ether --rpc-url <RPC_URL> --private-key <KEY>
```

## References

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Chainlink VRF Documentation](https://docs.chain.link/vrf/)
- [Ethereum Development Best Practices](https://ethereum.org/en/developers/)

## Credits

This project is built as part of the **Cyfrin Updraft Foundry Fundamentals** course, specifically the Smart Contract Lottery module. [Cyfrin Updraft](https://updraft.cyfrin.io/) has trained thousands of developers in Solidity, Foundry, and Web3 security, and this lottery is adapted from its hands-on curriculum as a practical, recruiter-ready example.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve the project. For major changes, please open an issue first to discuss what you would like to change.

## Support

For questions or issues, please open a GitHub issue or reach out via the Cyfrin Updraft community channels.
