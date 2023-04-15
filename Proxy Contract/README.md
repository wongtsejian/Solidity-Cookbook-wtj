# Proxy Smart Contract
A proxy smart contract is a type of smart contract that allows for the upgradeability of other contracts in the Ethereum ecosystem. With a proxy smart contract, developers can change the behavior of a contract without having to redeploy it or migrate its data to a new contract.

## How to use this example
npm install 

## How it Works
A proxy smart contract works by delegating calls to another contract known as the implementation contract. The proxy contract does not contain the logic of the contract it is proxying for, but rather, it contains the address of the implementation contract and forwards any calls made to it.

When a user interacts with the proxy contract, the proxy contract simply forwards the call to the implementation contract. The implementation contract executes the logic and returns the result to the proxy contract, which then returns the result to the user.

The key advantage of using a proxy smart contract is that it allows for the upgradeability of the implementation contract. Instead of deploying a new contract with new logic, developers can simply deploy a new implementation contract and update the address in the proxy contract to point to the new implementation. This allows for the contract to evolve over time without disrupting its users.

Proxy Patterns
There are several patterns for implementing proxy smart contracts, each with its own trade-offs. Here are three popular patterns:

### Transparent Proxy
The transparent proxy pattern is the simplest and most straightforward pattern for implementing a proxy smart contract. With this pattern, the proxy contract is simply a thin wrapper around the implementation contract. 

The proxy contract will call the implementation contract via a fallback() function

### Upgradeable Proxy
The upgradeable proxy pattern allows for the upgradeability of both the implementation contract and the proxy contract. With this pattern, there is a separate contract known as the proxy admin contract that is responsible for upgrading both the proxy contract and the implementation contract. This adds an extra layer of complexity, but also provides more control over the upgrade process.

### Eternal Storage Proxy
The eternal storage proxy pattern separates the data storage from the implementation contract. With this pattern, the data is stored in a separate contract known as the eternal storage contract, while the implementation contract contains only the logic. The proxy contract then delegates calls to both the implementation contract and the eternal storage contract.