# Source code of boido token
### Boido contract uses openzeppelin ERC1155 contract as its base and also includes extra features like presale.


Remember to fork this repository<br>
```
git clone https://github.com/seymuromarov/boido_token.git
cd boido_token
```

Deploy Solidity smart contracts with:
```
npm install
Create secrets.json and fill it
truffle deploy
```

Deploy Frontend:
```
cd boido_dapp
npm install
Set your testnet values on .env and mainnet on .env.production 
npm run build
```
