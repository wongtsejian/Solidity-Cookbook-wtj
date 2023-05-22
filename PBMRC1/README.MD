# Overview
Copy the shell.nix and package.json to setup a basic solidity dev environment out of the box.

# Nix 

- If you do not have nix, go to https://nixos.org/download.html 
- install Single-user installation by running the command `$ sh <(curl -L https://nixos.org/nix/install) --no-daemon` 

# Setting up Nix environment for PBMRC1
- Clone this repository in to your local drive
- Navigate to this repository
- Run `nix-shell` command in terminal to start the shell with all the dev environment required. The following dependencies (see package.json file for details) will be installed:
  - nodejs version 18
  - hardhat and hardhat plugins
  - chai
  - ethereum-waffle
  - ethers
  - solidity-coverage
  - @openzeppelin/contracts

