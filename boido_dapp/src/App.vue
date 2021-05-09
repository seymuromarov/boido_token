<template>
    <div
            id="sideNav"
            :class="[{ collapsed: collapsed }, { onmobile: isOnMobile }]"
    >
        <div class="sideNav">
            <div>
                <div class="row">
                    <div class="col">
                        <h1>
                            <img src="./assets/logo.png" width="60" class="tour1"/>
                            Boido
                        </h1>
                    </div>
                    <div class="col">
                        <button class="fill-button float-right" v-if="account">
                            {{ shortAddress }}
                        </button>
                        <button
                                class="fill-button float-right"
                                v-if="!account"
                                @click="connect"
                        >
                            Connect
                        </button>
                    </div>
                </div>
                <hr style="margin: 50px 0px; border: 1px solid #e3e3e3"/>
                <router-view/>
            </div>
            <sidebar-menu
                    :menu="menu"
                    :collapsed="collapsed"
                    :theme="selectedTheme"
                    :show-one-child="true"
                    @toggle-collapse="onToggleCollapse"
                    @item-click="onItemClick"
            >
        <span slot="toggle-icon"
        ><font-awesome-icon icon="expand-arrows-alt"
        /></span>
            </sidebar-menu>
            <div
                    v-if="isOnMobile && !collapsed"
                    class="sidebar-overlay"
                    @click="collapsed = true"
            />
        </div>
    </div>
</template>

<script>
  import Web3 from "web3";
  import Voido from "../../build/contracts/Voido";
  import Shepherd from "shepherd.js";

  const separator = {
    template: `<hr style="border-color: rgba(0, 0, 0, 0.1); margin: 20px;">`,
  };

  export default {
    name: "App",
    data() {
      return {
        menu: [
          {
            header: true,
            title: "Boidos",
            hiddenOnCollapse: true,
          },
          {
            href: "/",
            title: "Get Your Boido",

            icon: {
              element: "font-awesome-icon",
              attributes: {
                icon: "cubes",
              },
            },
          },
          {
            href: "/all",
            title: "Released Boidos",
            icon: {
              element: "font-awesome-icon",
              attributes: {
                icon: "table",
              },
            },
          },
          {
            header: true,
            title: "Wallet",
            hiddenOnCollapse: true,
          },
          {
            href: "/profile",
            title: "My Boidos",

            icon: {
              element: "font-awesome-icon",
              attributes: {
                icon: "wallet",
              },
            },
          },
          {
            href: "/trade",
            title: "Trade",

            icon: {
              element: "font-awesome-icon",
              attributes: {
                icon: "exchange-alt",
              },
            },
          },
          {
            href: "/battle",
            title: "Battlegrounds",

            icon: {
              element: "font-awesome-icon",
              attributes: {
                icon: "dice-d20",
              },
            },
          },
        ],
        collapsed: false,
        selectedTheme: "dark",
        isOnMobile: false,
        web3: null,
        account: null,
        contractInstance: null,
      };
    },
    mounted() {
      this.onResize();
      this.connect();
      window.addEventListener("resize", this.onResize);
      //  TOUR
      this.$nextTick(() => {
        const tour = new Shepherd.Tour({
          defaultStepOptions: {
            // classes: "popup-dark popup-dark-text",
            scrollTo: true,
            useModalOverlay: true,
          },
        });
        tour.addStep({
          id: "tour1",
          attachTo: {element: ".tour1", on: "auto"},
          title: "Hello, I am Boido-chan!",
          text:
            '<img src="https://boido.org/cdn/images/boido.webp" width="100%" />',
          buttons: [
            {
              text: "Skip",
              action: tour.complete,
            },
            {
              text: "Next",
              action: tour.next,
            },
          ],
          cancelIcon: {
            enabled: true,
          },
        });

        tour.addStep({
          id: "tour2",
          attachTo: {element: "", on: "auto"},
          title: "I’m here to explain how you can get your NFT!",
          text:
            '<img src="https://boido.org/cdn/images/boido.webp" width="100%" />',
          buttons: [
            {
              text: "Back",
              action: tour.back,
            },
            {
              text: "Next",
              action: tour.next,
            },
          ],
          cancelIcon: {
            enabled: true,
          },
        });

        tour.addStep({
          id: "tour3",
          attachTo: {element: ".fill-button", on: "auto"},
          title: "First you need to connect to your metamask wallet",
          text:
            '<img src="https://boido.org/cdn/images/boido.webp" width="100%" />',
          buttons: [
            {
              text: "Back",
              action: tour.back,
            },
            {
              text: "Next",
              action: tour.next,
            },
          ],
          cancelIcon: {
            enabled: true,
          },
        });

        tour.addStep({
          id: "tour4",
          attachTo: {element: "", on: "auto"},
          title: "This is the screen where you can choose your NFT.",
          text:
            '<img src="https://boido.org/cdn/images/boido.webp" width="100%" />',
          buttons: [
            {
              text: "Back",
              action: tour.back,
            },
            {
              text: "Next",
              action: tour.next,
            },
          ],
          cancelIcon: {
            enabled: true,
          },
        });

        tour.addStep({
          id: "tour5",
          attachTo: {element: "", on: "auto"},
          title: "Select the one you like and click the buy button!",
          text:
            '<img src="https://boido.org/cdn/images/boido.webp" width="100%" />',
          buttons: [
            {
              text: "Back",
              action: tour.back,
            },
            {
              text: "Thanks",
              action: tour.next,
            },
          ],
          cancelIcon: {
            enabled: true,
          },
        });
        if (!this.$cookies.get("tour-complete")) {
          tour.start()
        }
        Shepherd.on("complete", () => {
          this.$cookies.set('tour-complete', true);
        })
      });
    },
    computed: {
      shortAddress() {
        return this.account.substr(0, 4) + "..." + this.account.substr(-4, 4);
      },
    },
    methods: {
      async changeNetworkToBsc() {
        // let nodes = [NODE_1, NODE_2, NODE_3]
        let nodes = [process.env.VUE_APP_CHAIN_NODE_1]
        const provider = window.ethereum
        const chainId = parseInt(process.env.VUE_APP_CHAIN_ID)
        try {
          await provider.request({
            method: 'wallet_addEthereumChain',
            params: [
              {
                chainId: `0x${chainId.toString(16)}`,
                chainName: process.env.VUE_APP_CHAIN_NAME,
                nativeCurrency: {
                  name: 'BNB',
                  symbol: 'bnb',
                  decimals: 18,
                },
                rpcUrls: nodes,
                blockExplorerUrls: [process.env.VUE_APP_CHAIN_EXPLORER],
              },
            ],
          })
          return true
        } catch (error) {
          console.error(error)
          return false
        }
      },
      async connect() {
        // console.log(window.ethereum)
        if (window.ethereum) {
          await window.ethereum.enable();
          this.web3 = new Web3(window.ethereum);
          let chainId = await this.web3.eth.getChainId()
          // console.log(chainId)
          if (chainId !== parseInt(process.env.VUE_APP_CHAIN_ID)) {
            this.changeNetworkToBsc()
          } else {
            let accounts = await this.web3.eth.getAccounts();
            this.account = accounts[0];
          }

          window.ethereum.on("accountsChanged", (accounts) => {
            this.onAddressChange(accounts);
          });

          window.ethereum.on("networkChanged", (networkId) => {
            this.onNetworkChange(networkId)
            // Time to reload your interface with the new networkId
          });

        }
      },
      async onAddressChange(account) {
        if (window.ethereum) {
          let accounts = await this.web3.eth.getAccounts();
          this.account = accounts[0];
          // console.log(accounts[0]);
        }
      },
      async onNetworkChange(networkId) {
        // console.log(networkId)
        if (window.ethereum) {
          if (networkId !== process.env.VUE_APP_CHAIN_ID) {
            this.account = null
          } else {
            let accounts = await this.web3.eth.getAccounts();
            this.account = accounts[0];
          }
        }
      },

      onToggleCollapse(collapsed) {
        // console.log(collapsed);
        this.collapsed = collapsed;
      },
      onItemClick(event, item, node) {
        // console.log("onItemClick");
      },
      onResize() {
        if (window.innerWidth <= 1025) {
          this.isOnMobile = true;
          this.collapsed = true;
        } else {
          this.isOnMobile = false;
          this.collapsed = false;
        }
      },
    }
    ,
  }
  ;
</script>

<style lang="scss">
    @import url("https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600");
    //  TOUR:-
    // @import "~shepherd.js/dist/css/shepherd.css";

    body,
    html {
        margin: 0;
        padding: 0;
    }

    body {
        font-family: "Source Sans Pro", sans-serif;
        font-size: 18px;
        background: #232546 !important; /* fallback for old browsers */
        // background: -webkit-linear-gradient(
        //                 to right,
        //                 #243b55,
        //                 #141e30
        // ) !important; /* Chrome 10-25, Safari 5.1-6 */
        // background: linear-gradient(
        //                 to right,
        //                 #243b55,
        //                 #141e30
        // ) !important; /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */

        color: #fcfcfc !important;
    }

    // .popup-dark {
    //   background-color: #1c1c35 !important;
    //   color: #fff !important;
    // }
    // .popup-dark-text.shepherd-title{
    //   color: white !important
    // }
    #sideNav {
        padding-left: 350px;
        transition: 0.3s ease;
    }

    #sideNav.collapsed {
        padding-left: 50px;
    }

    #sideNav.onmobile {
        padding-left: 50px;
    }

    .sidebar-overlay {
        position: fixed;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-color: rgb(1, 46, 105);
        opacity: 0.5;
        z-index: 900;
    }

    .sideNav {
        padding: 50px;
    }

    .container {
        max-width: 900px;
    }

    .v-sidebar-menu {
        // background-color: #131418 !important;
        background: #1c1c35 !important; /* fallback for old browsers */

        .vsm--link_level-1 .vsm--icon {
            background-color: unset !important;
        }
    }

    pre {
        font-family: Consolas, monospace;
        color: rgb(173, 81, 81);
        background: rgb(34, 3, 3);
        border-radius: 2px;
        padding: 15px;
        line-height: 1.5;
        overflow: auto;
    }

    .fill-button:hover,
    .fill-button:focus {
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
            fill-button: #a972cb,
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

    .fill-button {
        color: var(--color);
        transition: 0.25s;

        &:hover,
        &:focus {
            border-color: var(--hover);
            color: #fff;
        }
    }

    // Basic button styles
    .fill-button {
        background: none;
        border: 2px solid;
        font: inherit;
        line-height: 1;
        margin: 0.5em;
        padding: 1em 2em;
    }
</style>
