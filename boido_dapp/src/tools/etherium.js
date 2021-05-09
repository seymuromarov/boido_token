import {ethers, Contract} from 'ethers';
import Web3 from 'web3';
import Voido from '../../../build/contracts/Voido.json';

const getBlockchain = () =>
  new Promise((resolve, reject) => {
    window.addEventListener('load', async () => {
      if (window.ethereum) {
        await window.ethereum.enable();
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const eth = new Web3(window.ethereum);
        const nft = new Contract(
          Voido.networks[window.ethereum.networkVersion].address,
          Voido.abi,
          signer
        );

        resolve({nft, eth: eth});
      }
      resolve({nft: undefined, eth: undefined});
    });
  });

export default getBlockchain;
