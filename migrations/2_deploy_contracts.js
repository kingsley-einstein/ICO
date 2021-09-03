const TokenSale = artifacts.require("TokenSale");

require("dotenv").config();

const { WITHDRAWAL_WALLET, TOKEN_ADDRESS } = process.env;

module.exports = async function (deployer) {
  await deployer.deploy(
    TokenSale,
    WITHDRAWAL_WALLET,
    0.0025 * 10 ** 18,
    TOKEN_ADDRESS
  );
};
