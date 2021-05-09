import Vue from 'vue'
import App from './App.vue'
// import './registerServiceWorker'
import router from './router'
import store from './store'
import VueSidebarMenu from 'vue-sidebar-menu'
import 'vue-sidebar-menu/dist/vue-sidebar-menu.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import './assets/main.scss';
import Cryptoicon from 'vue-cryptoicon';
import icon from 'vue-cryptoicon/src/icons';
import "noty/src/noty.scss";
import "noty/src/themes/mint.scss";
import mojs from  '@mojs/core'
import VueTour from 'vue-tour'
import VueCookies from 'vue-cookies'

import {library} from '@fortawesome/fontawesome-svg-core'
import {
  faCubes,
  faTable,
  faWallet,
  faExchangeAlt,
  faDiceD20,
  faExpandArrowsAlt,
  faUsers,
  faEye,
  faTags
} from '@fortawesome/free-solid-svg-icons'
import {FontAwesomeIcon} from '@fortawesome/vue-fontawesome'

let axiosDefaults = require("axios/lib/defaults");

library.add(faUsers, faCubes, faTable, faWallet, faExchangeAlt, faDiceD20, faExpandArrowsAlt, faEye, faTags)
// axiosDefaults.baseURL = "https://api.boido.org";
axiosDefaults.baseURL = "http://127.0.0.1:8000";


Cryptoicon.add(icon);

Vue.component('font-awesome-icon', FontAwesomeIcon)

require('vue-tour/dist/vue-tour.css')

Vue.use(VueTour)
Vue.use(VueSidebarMenu)
Vue.use(Cryptoicon);

Vue.use(VueCookies)
Vue.$cookies.config('365d')


Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
