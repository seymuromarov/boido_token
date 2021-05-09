import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
  },
  mutations: {
  },
  actions: {
  },
  modules: {
  },
  getters: {
    boido: (state) => (id) => {
      return state.cards.filter(p => p.id === Number(id))[0]
    }
  }
})
