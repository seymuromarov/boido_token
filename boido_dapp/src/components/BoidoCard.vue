<template>
    <div class="col-lg-4 col-md-4 col-sm-12">
        <section class="mt-3 shadow-lg">
            <div class="cardGlass">
                <div class="row">
                    <div class="col-6">
                        <p class="mt-2 text-center">
                            {{ card.name }} <span class="rank">{{ card.rank != null ? card.rank.name : "" }}</span>
                        </p>
                    </div>
                    <div class="col-6">
                        <p class="mt-2 text-center" v-if="card.amount">
                            Amount : {{ card.amount }}
                        </p>
                    </div>
                </div>
                <router-link :to="{ name: 'Boido', params: { id: card.id } }">
                    <img class="img-fluid" :src="card.image"/>
                </router-link>
                <div class="row">
                    <div class="col-6">
                        <div class="cybr-btn mt-2 ml-0 mb-2 pl-1 text-center">
                            <span class="glitchout">Power <span aria-hidden>/</span></span>
                            {{card.attributes.find(element => element.trait_type == "attack").value}}

                            <span aria-hidden class="cybr-btn__glitch">Power_</span>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="cybr-btn mt-2 mr-1 mb-2 health pl-1 text-center">
                            <span class="glitchout">Health <span aria-hidden>/</span></span>
                            {{card.attributes.find(element => element.trait_type == "defence").value}}
                            <span aria-hidden class="cybr-btn__glitch">Health_</span>
                        </div>
                    </div>
                </div>
                <div class="flex-center mb-2 mt-2 row">
                    <div class="mt-2 flex-center col" v-if="card.buy_id">
                        PRICE: {{ price }}
                        <cryptoicon class="ml-1" symbol="bnb" size="24"/>
                    </div>
                    <div class="flex-center col">
                        <button
                                class="btn-shine"
                                v-if="card.buy_id"
                                @click="$emit('buy', card.buy_id)"
                        >
                            <span style="color: #ffffff">BUY</span>
                        </button>
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<script>
  export default {
    props: {
      card: {
        type: Object,
        required: true,
      },
    },
    computed: {
      price: function () {
        return parseInt(this.card.price_in_wei) / 1000000000000000000
      },
    },
  };
</script>


<style scoped lang="scss">
    @media screen and (max-width: 600px) {
        .glitchout {
            display: none;
        }
    }

    .health.cybr-btn {
        --primary-hue: 0;
    }

    .flex-center {
        display: flex;
        justify-content: center;
        font-family: "Cyber", sans-serif;
    }

    .cardGlass {
        background: rgba(255, 255, 255, 0.05);
        box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        border-radius: 10px;
        border: 1px solid rgba(255, 255, 255, 0.18);
        margin-left: 10px;
    }

    .rank {
        color: #f9689a;
        text-shadow: -3px -3px 0 #77caff;
    }

    button {
        position: relative;
        margin: 0;
        padding: 5px 12px;
        height: 50px;
        width: 135px;
        outline: none;
        text-decoration: none;
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        /*text-transform: uppercase;*/
        background-color: #7258e9;
        border: 1px solid rgba(22, 76, 167, 0.6);
        border-radius: 10px;
        color: #010810;
        font-weight: 400;
        font-size: 20px;
        font-family: inherit;
        z-index: 0;
        overflow: hidden;
        transition: all 0.3s cubic-bezier(0.02, 0.01, 0.47, 1);

        span {
            color: #164ca7;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 0.7px;
        }

        &:hover {
            animation: rotate 0.7s ease-in-out both;

            span {
                animation: storm 0.7s ease-in-out both;
                animation-delay: 0.06s;
            }
        }
    }

    @keyframes rotate {
        0% {
            transform: rotate(0deg) translate3d(0, 0, 0);
        }
        25% {
            transform: rotate(3deg) translate3d(0, 0, 0);
        }
        50% {
            transform: rotate(-3deg) translate3d(0, 0, 0);
        }
        75% {
            transform: rotate(1deg) translate3d(0, 0, 0);
        }
        100% {
            transform: rotate(0deg) translate3d(0, 0, 0);
        }
    }

    @keyframes storm {
        0% {
            transform: translate3d(0, 0, 0) translateZ(0);
        }
        25% {
            transform: translate3d(4px, 0, 0) translateZ(0);
        }
        50% {
            transform: translate3d(-3px, 0, 0) translateZ(0);
        }
        75% {
            transform: translate3d(2px, 0, 0) translateZ(0);
        }
        100% {
            transform: translate3d(0, 0, 0) translateZ(0);
        }
    }

    .btn-pill {
        &:before,
        &:after {
            position: absolute;
            right: 0;
            bottom: 0;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: #1d89ff;
            content: "";
            opacity: 0;
            transition: transform 0.15s cubic-bezier(0.02, 0.01, 0.47, 1),
            opacity 0.15s cubic-bezier(0.02, 0.01, 0.47, 1);
            z-index: -1;
            transform: translate(100%, -25%) translate3d(0, 0, 0);
        }

        &:hover {
            &:before,
            &:after {
                opacity: 0.15;
                transition: transform 0.2s cubic-bezier(0.02, 0.01, 0.47, 1),
                opacity 0.2s cubic-bezier(0.02, 0.01, 0.47, 1);
            }

            &:before {
                transform: translate3d(50%, 0, 0) scale(0.9);
            }

            &:after {
                transform: translate(50%, 0) scale(1.1);
            }
        }
    }

    .btn-shine {
        border: 1px solid;
        overflow: hidden;
        position: relative;

        span {
            z-index: 20;
        }

        &:after {
            background: #38ef7d;
            content: "";
            height: 155px;
            left: -75px;
            opacity: 0.4;
            position: absolute;
            top: -50px;
            transform: rotate(35deg);
            transition: all 550ms cubic-bezier(0.19, 1, 0.22, 1);
            width: 50px;
            z-index: -10;
        }

        &:hover {
            &:after {
                left: 120%;
                transition: all 550ms cubic-bezier(0.19, 1, 0.22, 1);
            }
        }
    }

    .btn-slide-line {
        &.center {
            &:after {
                left: 50%;
            }
        }

        &:after {
            position: absolute;
            right: 0;
            left: auto;
            transition: 0.3s;
            content: "";
            width: 0;
            bottom: 0;
            height: 3px;
            background: #164ca7;
        }

        &:hover {
            cursor: pointer;

            &:after {
                width: 100%;
                left: 0;
            }
        }
    }

    .inspire {
        a {
            text-decoration: none;
        }
    }
</style>
