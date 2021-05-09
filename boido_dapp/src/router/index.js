import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/about',
    name: 'About',
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  },
  {
    path: '/token',
    name: 'Token',
    component: () => import(/* webpackChunkName: "about" */ '../views/Token.vue')
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import(/* webpackChunkName: "about" */ '../pages/Profile.vue')
  },
  {
    path: '/all',
    name: 'Tokens',
    component: () => import(/* webpackChunkName: "about" */ '../pages/Tokens.vue')
  },
  {
    path: '/trade',
    name: 'Trade',
    component: () => import(/* webpackChunkName: "about" */ '../pages/Trade.vue')
  },
   {
    path: '/boidos/:id',
    name: 'Boido',
    component: () => import(/* webpackChunkName: "about" */ '../views/Boido.vue')
  }

]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
