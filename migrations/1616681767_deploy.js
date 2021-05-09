const Voido = artifacts.require("Voido");

module.exports = function (deployer) {
  deployer.deploy(Voido, "https://api.boido.org/tokens/{id}.json")
    // Option 2) Console log the address:
    .then(() => console.log(Voido.address));

};
