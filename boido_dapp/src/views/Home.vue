<template>
    <main class="">
        <v-tour name="myTour" :steps="steps"></v-tour>
        <slot/>
<!--        <h2 class="mb-8 text-4xl font-bold text-center">-->
<!--            Cards Rarity :-->
<!--            <span>All</span>-->
<!--        </h2>-->

        <BoidoList :cards="cards" @buy="buy($event)"/>
    </main>
</template>

<script>
  import BoidoFilter from "@/components/BoidoFilter.vue";
  import BoidoList from "@/components/BoidoList.vue";

  import axios from "axios";
  import Web3 from "web3";
  import Voido from "../../../build/contracts/Voido";
  import Noty from 'noty';

  // import data from "../tests.json"
  let animation = {
    open: function (promise) {
      var n = this;
      var Timeline = new mojs.Timeline();
      var body = new mojs.Html({
        el: n.barDom,
        x: {500: 0, delay: 0, duration: 500, easing: 'elastic.out'},
        isForce3d: true,
        onComplete: function () {
          promise(function (resolve) {
            resolve();
          })
        }
      });

      var parent = new mojs.Shape({
        parent: n.barDom,
        width: 200,
        height: n.barDom.getBoundingClientRect().height,
        radius: 0,
        x: {[150]: -150},
        duration: 1.2 * 500,
        isShowStart: true
      });

      n.barDom.style['overflow'] = 'visible';
      parent.el.style['overflow'] = 'hidden';

      var burst = new mojs.Burst({
        parent: parent.el,
        count: 10,
        top: n.barDom.getBoundingClientRect().height + 75,
        degree: 90,
        radius: 75,
        angle: {[-90]: 40},
        children: {
          fill: '#EBD761',
          delay: 'stagger(500, -50)',
          radius: 'rand(8, 25)',
          direction: -1,
          isSwirl: true
        }
      });

      var fadeBurst = new mojs.Burst({
        parent: parent.el,
        count: 2,
        degree: 0,
        angle: 75,
        radius: {0: 100},
        top: '90%',
        children: {
          fill: '#EBD761',
          pathScale: [.65, 1],
          radius: 'rand(12, 15)',
          direction: [-1, 1],
          delay: .8 * 500,
          isSwirl: true
        }
      });

      Timeline.add(body, burst, fadeBurst, parent);
      Timeline.play();
    },
    close: function (promise) {
      var n = this;
      new mojs.Html({
        el: n.barDom,
        x: {0: 500, delay: 10, duration: 500, easing: 'cubic.out'},
        skewY: {0: 10, delay: 10, duration: 500, easing: 'cubic.out'},
        isForce3d: true,
        onComplete: function () {
          promise(function (resolve) {
            resolve();
          })
        }
      }).play();
    }
  };
  export default {
    name: "Home",
    components: {
      BoidoFilter,
      BoidoList,
    },
    data: function () {
      return {
        cards: [],
        steps: [
          {
            target: "#v-step-0", // We're using document.querySelector() under the hood
            content: `Discover <strong>Vue Tour</strong>!`,
          },
          {
            target: ".v-step-1",
            content: "An awesome plugin made with Vue.js!",
          },
          {
            target: '[data-v-step="2"]',
            content:
              "Try it, you'll love it!<br>You can put HTML in the steps and completely customize the DOM to suit your needs.",
            params: {
              placement: "top",
            },
          },
        ],
        web3: null,
        account: null,
        contractInstance: null,
        tokens: null,
        tokenCount: 0,
        // cards: data.cards
      };
    },
    mounted: function () {
      // this.$tours['myTour'].start()
    },
    beforeMount() {
      this.initContract();
    },

    methods: {
      async initContract() {
        console.log("rarar");
        this.fetchCards();

        if (window.ethereum) {
          await window.ethereum.enable();
          this.web3 = new Web3(window.ethereum);
          let accounts = await this.web3.eth.getAccounts();
          this.account = accounts[0];
          // if (window.ethereum.networkVersion == 56) {
          this.contractInstance = new this.web3.eth.Contract(
            Voido.abi,
            Voido.networks[window.ethereum.networkVersion].address
          );

          // }
          console.log(window.ethereum.networkVersion);

          window.ethereum.on("accountsChanged", (accounts) => {
            this.onAddressChange(accounts);
          });

          window.ethereum.on("networkChanged", function (networkId) {
            console.log();
            // Time to reload your interface with the new networkId
          });
        } else {
          new Noty({
            type: 'error',
            layout: 'topRight',
            text: 'Please install metamask or another web3 client',
            animation: animation
          }).show();

        }
        // console.log(this.web3.utils.toWei('0.1', 'ether'))
      },
      async onAddressChange(accountsSd) {
        if (window.ethereum) {
          let accounts = await this.web3.eth.getAccounts();
          console.log(accountsSd);
          console.log(accounts[0]);
        }
      },

      async fetchCards() {

        try {
          const url = "/presale";
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
      async getTokensCount() {
        let {data} = await axios.get("/count/tokens");
        this.tokenCount = data;
      },
      renderCards(results) {
        console.log(results)
        this.cards = results.map((card) => ({
          ...card,
          name: card.name,
          description: card.description,
          image: card.image,
          amount: card.amount,
          buy_id: card.id,
          attributes: card.attributes
        }));
      },
      async buy(id) {
        console.log("buying:" + id);
        const response = await axios.get("/tokens/" + id);
        const tokenData = response.data;

        this.contractInstance.methods
          .buyItemFromPreSale(id, "1", this.account, process.env.VUE_APP_CONTRACT_OWNER_ADDRESS)
          .send({
            from: this.account,
            // value: this.web3.utils.toWei('0.001', 'ether')
            value: tokenData.price_in_wei,
          })
          .then((receipt) => {
            console.log(receipt);
            this.isLoading = false;
            this.$router.push({path: "/profile"});
            new Noty({
              type: 'success',
              layout: 'topLeft',
              text: 'Successful buy',
              timeout: 1500,
              animation: animation
            }).show();

          })
          .catch((err) => {
            console.log(err, "err");
            this.isLoading = false;
            new Noty({
              type: 'error',
              layout: 'topLeft',
              text: 'Error while buying',
              timeout: 5000,
              animation: animation
            }).show();
          });
        new Noty({
          type: 'info',
          layout: 'topLeft',
          text: 'Please wait , we will redirect you after blockchain confirmation',
          timeout: 2200,
          animation: animation
        }).show();
      },
    },
  };
</script>

<style scoped></style>
