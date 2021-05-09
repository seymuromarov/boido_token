<template>
  <main class="">

    <v-tour name="myTour" :steps="steps"></v-tour>
    <slot />
<!--    <h2 class="mb-8 text-4xl font-bold text-center">-->
<!--      Cards Rarity :-->
<!--      <span>All</span>-->
<!--    </h2>-->

    <BoidoList :cards="cards" />

  </main>
</template>

<script>
import BoidoFilter from '@/components/BoidoFilter.vue'
import BoidoList from '@/components/BoidoList.vue'

import axios from 'axios'
import Web3 from "web3";
import Voido from "../../../build/contracts/Voido";

// import data from "../tests.json"

export default {
  name: 'Home',
  components: {
    BoidoFilter,
    BoidoList,
  },
  data: function () {
    return {
      cards: [],
      steps: [
        {
          target: '#v-step-0', // We're using document.querySelector() under the hood
          content: `Discover <strong>Vue Tour</strong>!`,
        },
        {
          target: '.v-step-1',
          content: 'An awesome plugin made with Vue.js!',
        },
        {
          target: '[data-v-step="2"]',
          content:
            "Try it, you'll love it!<br>You can put HTML in the steps and completely customize the DOM to suit your needs.",
          params: {
            placement: 'top',
          },
        },
      ],
      web3: null,
      account: null,
      contractInstance: null,
      tokens: null,
      tokenCount: 0,

      // cards: data.cards
    }
  },
 mounted: function () {
      // this.$tours['myTour'].start()
    },
  beforeMount() {
    this.initContract()
  },

  methods: {
    async initContract() {
      // this.contractInstance = new this.web3.eth.Contract(Voido.abi, Voido.networks[window.ethereum.networkVersion].address);
      this.fetchCards()
    },

    async fetchCards() {
      try {
        const url = '/tokens'
        const response = await axios.get(url)
        const results = response.data
        this.renderCards(results)
      } catch (err) {
        if (err.response) {
          // client received an error response (5xx, 4xx)
          console.log('Server Error:', err)
        } else if (err.request) {
          // client never received a response, or request never left
          console.log('Network Error:', err)
        } else {
          console.log('Client Error:', err)
        }
      }
    },
    renderCards(results) {
      this.cards = results.map((card) => ({
        ...card,
        name: card.name,
        description: card.description,
        image: card.image,
        attributes: card.attributes

      }))

    },


  },
}
</script>

<style scoped></style>
