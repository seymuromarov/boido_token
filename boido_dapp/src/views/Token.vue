<template>
    <div class="home">
        {{tokenResult}}
        <button v-on:click="buy"> Buy me</button>
    </div>
</template>

<script>
  import getBlockchain from '../tools/etherium.js';
  import axios from 'axios';
  import Voido from '../../../build/contracts/Voido.json';

  // @ is an alias to /src
  import HelloWorld from '@/components/HelloWorld.vue'

  export default {
    name: 'Home',
    components: {
      HelloWorld
    },
    data: function () {
      return {
        tokenResult: null,
        web3: null,
        account: null,
        contractInstance: null,
        gene: null,
        matron: null,
        sire: null,
        vipers: [],
        isLoading: false,
        nft: null

      }
    },
    mounted() {
      this.initContract()
    },

    methods: {
      async initContract() {
        this.web3 = await getBlockchain();
        console.log(this.web3)
        console.log(this.web3.eth.utils.toWei('0.02', 'ether'))
        this.web3.eth.eth.getAccounts().then((accounts) => {
          [this.account] = accounts;
        }).catch((err) => {
          console.log(err, 'err!!');
        });
        this.contractInstance = new this.web3.eth.eth.Contract(Voido.abi, Voido.networks[window.ethereum.networkVersion].address);

        this.nft = this.web3.nft;
        const tokenURI = await this.nft.tokenURI(0);
        const {data} = await axios.get(tokenURI);
        console.log(data)
        this.tokenResult = data;
        console.log(this.nft)

      },
      async buy() {
        console.log(this.account)
        this.contractInstance.methods.buyItemFromPreSale("1","1","0x2F54db9f79bA065e78Bb6B648C049e1DdA02bF7D","0x751D62BA409a006caaD12E09eB2044d05e20F8AE").send({
          from: this.account,
          value: this.web3.eth.utils.toWei('0.1', 'ether')
        }).then((receipt) => {
          console.log(receipt)
          this.isLoading = false;
        }).catch((err) => {
          console.log(err, 'err');
          this.isLoading = false;
        });
        // this.contractInstance.methods.depositMoney(1).send({
        //   from: this.account,
        //   value: this.web3.eth.utils.toWei('0.00001', 'ether')
        // }).then((receipt) => {
        //   console.log(receipt)
        //   this.isLoading = false;
        // }).catch((err) => {
        //   console.log(err, 'err');
        //   this.isLoading = false;
        // });

      }
    },
  }
</script>
