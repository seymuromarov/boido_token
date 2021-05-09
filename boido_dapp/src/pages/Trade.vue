<template>
  <main class="">
    <!-- <slot />
    <h2 class="mb-8 text-4xl font-bold text-center">Trade Boidos</h2>
      <BoidoList :cards="cards" @trade="trade($event)" /> -->
      <h2 class="text-center"> COMING SOON </h2>
    <!-- </router-link> -->
  </main>
</template>

<script>
import axios from "axios";
import Voido from "../../../build/contracts/Voido.json";
import Web3 from "web3";
import BoidoList from "@/components/BoidoList.vue";

export default {
  name: "Trade",
  components: {
    BoidoList,
  },
  data: function () {
    return {
      cards: [],
      web3: null,
      account: null,
      contractInstance: null,
      tokens: null,
      tokenCount: 0,
    };
  },

  beforeMount() {
    this.initContract();
  },

  methods: {
    async initContract() {
      // this.contractInstance = new this.web3.eth.Contract(Voido.abi, Voido.networks[window.ethereum.networkVersion].address);
      this.fetchCards();
    },

    async fetchCards() {
      try {
        const url = "/tokens";
        const response = await axios.get(url);
        const results = response.data;
        this.renderCards(results);
      } catch (err) {
        if (err.response) {
          // client received an error response (5xx, 4xx)
          console.log("Server Error:", err);
        } else if (err.request) {
          // client never received a response, or request never left
          console.log("Network Error:", err);
        } else {
          console.log("Client Error:", err);
        }
      }
    },
    renderCards(results) {
      this.cards = results.map((card) => ({
        ...card,

        name: card.name,
        description: card.description,
        image: card.image,
        trade_id: card.id,
      }));
    },

    async trade(id) {
      console.log("trade:" + id);
      const response = await axios.get("/tokens/" + id);
      const tokenData = response.data;

    },
  },
};

// export default {
//   name: 'Trade',
//   components: {
//     BoidoList,
//   },
//   data: function () {
//     return {
//       tokenResult: null,
//       web3: null,
//       account: null,
//       contractInstance: null,
//       isLoading: false,
//       nft: null,
//       tokens: null,
//       cards: [],
//       tokenCount: 0,

//     }
//   },
//   mounted() {
//     console.log('rasengan')
//     this.initContract()
//   },

//   methods: {
//     async initContract() {
//       console.log('rarar')
//       if (window.ethereum) {
//         await window.ethereum.enable();
//       } else {
//         alert("please enable web3 for viewing your profile")
//       }
//       this.web3 = new Web3(window.ethereum);
//       let accounts = await this.web3.eth.getAccounts()
//       this.account = accounts[0]
//       this.contractInstance = new this.web3.eth.Contract(Voido.abi, Voido.networks[window.ethereum.networkVersion].address);
//       await this.getTokens()
//     },
//     async getTokens() {
//       const response = await axios.get('/profile/' + this.account, {
//         // params: {
//         //   token_ids: userHaveTokens.toString()
//         // }
//       })
//       const results = response.data
//       this.renderCards(results)
//       console.log(results)
//     },
//     async getTokensCount() {
//       let {data} = await axios.get('/count/tokens')
//       this.tokenCount = data
//     },
//     renderCards(results) {
//       this.cards = results.map((card) => ({
//         name: card.name,
//         description: card.description,
//         rank: card.rank.name,
//         image: card.image,
//         amount: card.amount
//       }))

//     },
//     async sell(id) {
//       this.contractInstance.methods.setForSale(id, "1", this.web3.utils.toWei('0.1', 'ether')).send({
//         from: this.account,
//         // value: tokenData.price_in_wei
//       }).then((receipt) => {
//         console.log(receipt)
//         this.isLoading = false;
//         // alert("success")

//       }).catch((err) => {
//         console.log(err, 'err');
//       });

//     },
//     async cancelOrder(id) {
//       this.contractInstance.methods.removeFromSale(id).send({
//         from: this.account,
//       }).then((receipt) => {
//         console.log(receipt)
//         this.isLoading = false;
//         // alert("success")

//       }).catch((err) => {
//         console.log(err, 'err');
//       });

//     },

//     async buy(id) {
//       this.contractInstance.methods.buyFromSale(id, "0x751D62BA409a006caaD12E09eB2044d05e20F8AE", "1").send({
//         from: this.account,
//         value: this.web3.utils.toWei('0.1', 'ether')
//       }).then((receipt) => {
//         console.log(receipt)
//         this.isLoading = false;
//         // alert("success")

//       }).catch((err) => {
//         console.log(err, 'err');
//       });

//     }
//   },
// }
</script>
