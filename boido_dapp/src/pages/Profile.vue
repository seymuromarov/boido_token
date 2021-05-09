<template>
    <div class="home">
        <BoidoList :cards="cards"/>
    </div>
</template>

<script>
  import axios from 'axios';
  import Voido from '../../../build/contracts/Voido.json';
  import BoidoList from "@/components/BoidoList";
  import Web3 from 'web3'


  export default {
    name: 'Profile',
    components: {
      BoidoList,
    },
    data: function () {
      return {
        tokenResult: null,
        web3: null,
        account: null,
        contractInstance: null,
        isLoading: false,
        nft: null,
        tokens: null,
        cards: [],
        tokenCount: 0,

      }
    },
    mounted() {
      console.log('rasengan')
      this.initContract()
    },

    methods: {
      async initContract() {
        console.log('rarar')
        if (window.ethereum) {
          await window.ethereum.enable();
        } else {
          alert("please enable web3 for viewing your profile")
        }
        this.web3 = new Web3(window.ethereum);
        let accounts = await this.web3.eth.getAccounts()
        this.account = accounts[0]
        this.contractInstance = new this.web3.eth.Contract(Voido.abi, Voido.networks[window.ethereum.networkVersion].address);
        await this.getUserTokens()
      },
      async getUserTokens() {
        // console.log(this.account)
        // await this.getTokensCount()
        // let tokensId = []
        // for (let i = 0; i < this.tokenCount; i++) {
        //   tokensId.push(i + 1)
        // }
        // let userHaveTokens = [];
        // this.tokens = await this.contractInstance.methods.balanceOfAccountTokens(this.account, tokensId).call()
        // for (let i = 0; i < this.tokenCount; i++) {
        //   if (this.tokens[i] != 0) {
        //     userHaveTokens.push(tokensId[i])
        //   }
        // }
        // console.log(userHaveTokens)
        await this.getTokens()
      },
      async getTokens() {
        const response = await axios.get('/profile/' + this.account, {
          // params: {
          //   token_ids: userHaveTokens.toString()
          // }
        })
        const results = response.data
        this.renderCards(results)
        console.log(results)
      },
      async getTokensCount() {
        let {data} = await axios.get('/count/tokens')
        this.tokenCount = data
      },
      renderCards(results) {
        this.cards = results.map((card) => ({
          ...card,
          name: card.name,
          description: card.description,
          image: card.image,
          amount : card.amount,
          attributes: card.attributes

        }))

      },
      async buy() {
        // this.contractInstance.methods.buyItemFromPreSale("1", "1", "0x2F54db9f79bA065e78Bb6B648C049e1DdA02bF7D", "0x751D62BA409a006caaD12E09eB2044d05e20F8AE").send({
        //   from: this.account,
        //   value: this.web3.utils.toWei('0.001', 'ether')
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
