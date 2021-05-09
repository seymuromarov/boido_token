import Noty from "noty";
<template>
    <div class="row">
        <BoidoCard :card="card"/>

        <div class="col-lg-8 col-md-8 col-sm-12 mt-3">
            <h2>{{ card.name }}</h2>
            <div class="p-3 mb-2 mt-2 buyCorner text-white">
                <span class="info">{{ card.description }}</span>
            </div>
            <div class="p-3 mb-2 mt-2 buyCorner text-white" v-if="card.amount > 0">
                <p>
                    Current Price: <span class="info"> {{ price }} BNB</span>
                </p>
                <button  class="fill" v-on:click='buy($route.params.id)'>Buy Now</button>
            </div>
            <div class="p-3 mb-2 mt-2 buyCorner text-white">
                <font-awesome-icon icon="tags"/>
                <span class="info">
                    Max Amount {{ card.rank!= null? card.rank.maxAmount : "" }}
                </span>
            </div>
        </div>
    </div>
</template>

<script>
  import axios from "axios";
  import BoidoCard from "../components/BoidoCard.vue";
  import Web3 from "web3";
  import Voido from "../../../build/contracts/Voido";
  import Noty from 'noty';

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
    name: "Boido",
    data() {
      return {
        card: {},
        //   boido: this.$store.getters.boido(this.$route.params.id)
      };
    },
    components: {
      BoidoCard,
    },
    mounted() {
      this.getBoido();
    },

    computed: {
      price: function () {
        return parseInt(this.card.price_in_wei) / 1000000000000000000
      },
    },

    methods: {
      async getBoido() {
        this.fetchCard();

        if (window.ethereum) {
          await window.ethereum.enable();
          this.web3 = new Web3(window.ethereum);
          let accounts = await this.web3.eth.getAccounts();
          this.account = accounts[0];
          this.contractInstance = new this.web3.eth.Contract(
            Voido.abi,
            Voido.networks[window.ethereum.networkVersion].address
          );
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
      },

      async onAddressChange(accountsSd) {
        if (window.ethereum) {
          let accounts = await this.web3.eth.getAccounts();
          console.log(accountsSd);
          console.log(accounts[0]);
        }
      },

      async fetchCard() {
        try {
          const response = await axios.get("/presale/" + this.$route.params.id);
          const result = response.data;
          console.log(result)
          this.card = result;

          console.log(result.name);

          console.log(result.rank);
          // this.renderCard(result);
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

      async buy(id) {
        console.log("buying:" + id);
        const response = await axios.get("/tokens/" + id);
        const tokenData = response.data;

        this.contractInstance.methods
          .buyItemFromPreSale(id, "1", this.account, process.env.VUE_APP_CONTRACT_OWNER_ADDRESS)
          .send({
            from: this.account,
            value: tokenData.price_in_wei,
          })
          .then((receipt) => {
            console.log(receipt);
            this.isLoading = false;
            new Noty({
              type: 'success',
              layout: 'topLeft',
              text: 'Successful buy',
              timeout: 1500,
              animation: animation
            }).show();
            this.$router.push({path: "/profile"});
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

<style scoped lang="scss">
    @import url("https://fonts.googleapis.com/css?family=Poppins:400,500,600,700,800,900");
    @import url("https://fonts.googleapis.com/css2?family=Fira+Sans:wght@300&display=swap");

    .title-up {
        font-family: "Poppins", sans-serif;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-size: 13px;
        line-height: 1.2;
        color: #fff;
        margin-top: 0;
        margin-bottom: 10px;
    }

    .info {
        padding-left: 10px;
        padding-right: 10px;
        font-family: "Fira Sans", sans-serif;
        font-size: 18px;
    }

    .buyCorner {
        background-color: #14213d;
    }

    .fill:hover,
    .fill:focus {
        box-shadow: inset 0 0 0 2em var(--hover);
    }

    // Animate the size, outside
    .pulse:hover,
    .pulse:focus {
        animation: pulse 1s;
        box-shadow: 0 0 0 2em rgba(#fff, 0);
    }

    @keyframes pulse {
        0% {
            box-shadow: 0 0 0 0 var(--hover);
        }
    }

    // Stack multiple shadows, one from the left, the other from the right
    .close:hover,
    .close:focus {
        box-shadow: inset -3.5em 0 0 0 var(--hover), inset 3.5em 0 0 0 var(--hover);
    }

    // Size can also be negative; see how it's smaller than the element
    .raise:hover,
    .raise:focus {
        box-shadow: 0 0.5em 0.5em -0.4em var(--hover);
        transform: translateY(-0.25em);
    }

    // Animating from the bottom
    .up:hover,
    .up:focus {
        box-shadow: inset 0 -3.25em 0 0 var(--hover);
    }

    // And from the left
    .slide:hover,
    .slide:focus {
        box-shadow: inset 6.5em 0 0 0 var(--hover);
    }

    // Multiple shadows, one on the outside, another on the inside
    .offset {
        box-shadow: 0.3em 0.3em 0 0 var(--color), inset 0.3em 0.3em 0 0 var(--color);

        &:hover,
        &:focus {
            box-shadow: 0 0 0 0 var(--hover), inset 6em 3.5em 0 0 var(--hover);
        }
    }

    //=== Set button colors
    // If you wonder why use Sass vars or CSS custom properties...
    // Make a map with the class names and matching colors
    $colors: (
            fill: #a972cb,
            pulse: #ef6eae,
            close: #ff7f82,
            raise: #ffa260,
            up: #e4cb58,
            slide: #8fc866,
            offset: #19bc8b,
    );

    // Sass variables compile to a static string; CSS variables are dynamic and inherited
    // Loop through the map and set CSS custom properties using Sass variables
    @each $button, $color in $colors {
        .#{$button} {
            --color: #{$color};
            --hover: #{adjust-hue($color, 45deg)};
        }
    }

    button {
        color: var(--color);
        transition: 0.25s;

        &:hover,
        &:focus {
            border-color: var(--hover);
            color: #fff;
        }
    }

    // Basic button styles
    button {
        background: none;
        border: 2px solid;
        font: inherit;
        line-height: 1;
        margin: 0.5em;
        padding: 1em 2em;
    }
</style>
