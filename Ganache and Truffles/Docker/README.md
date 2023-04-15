# Introduction
This cookbook will teach you how to deploy to a local chain (ganache) by using Docker files.

# Installation
- install docker
- install docker-compose
- orbstack

# Setup project
## Build Images
- docker files
docker-compose run --rm deployment-playground

## Initialize the project
- npm init
- .gitignore
- npm install --save truffle
npm exec truffle init

## Truffle Config
- Uncomment and setup
Copy


## Migration file
Copy


## Contract development
npm exec truffle create contract HelloWorld
Copy

npm exec truffle create test HelloWorld
https://trufflesuite.com/docs/truffle/how-to/debug-test/write-tests-in-javascript/

 npm exec truffle test ./test/hello_world.js
