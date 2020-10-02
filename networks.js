const mnemonic = "absent heavy face crawl mask blue because river bike lemon toy ability"
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      protocol: 'http',
      host: 'localhost',
      port: 8545,
      gas: 5000000,
      gasPrice: 5e9,
      networkId: '*',
    },

    rinkeby: {
      provider: () => new HDWalletProvider(
        mnemonic, "https://rinkeby.infura.io/v3/98ae0677533f424ca639d5abb8ead4e7"
      ),
      networkId: 4,
      gasPrice: 10e9
    }
  },
};
