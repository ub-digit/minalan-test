import { createRouter, createWebHistory } from 'vue-router'
import Summary from '@/views/Summary.vue'
import Charges from '@/views/Charges.vue'
import Details from '@/views/Details.vue'
import Messaging from '@/views/Messaging.vue'
import Barcode from '@/views/Barcode.vue'
import Login from '@/views/Login.vue'
import Overdues from '@/views/summary/Overdues.vue'
import Holds from '@/views/summary/Holds.vue'
import Checkouts from '@/views/summary/Checkouts.vue'
import NotFound from '@/components/NotFound.vue'

const routes = [
  {
    path: '/',
    name: 'Summary',
    component: Summary,
    meta: { auth: true },
    children: [
      {
        path: '/',
        name: 'Checkouts',
        component: Checkouts,
        meta: { auth: true }
      },
      {
        path: '/overdues',
        name: 'Overdues',
        component: Overdues,
        meta: { auth: true }
      },
      {
        path: '/holds',
        name: 'Holds',
        component: Holds,
        meta: { auth: true }
      }
    ]
  },
  {
    path: '/charges',
    name: 'Charges',
    component: Charges,
    meta: { auth: true }
  },
  {
    path: '/details',
    name: 'Details',
    component: Details,
    meta: { auth: true }
  },
  {
    path: '/messaging',
    name: 'Messaging',
    component: Messaging,
    meta: { auth: true }
  },
  {
    path: '/barcode',
    name: 'Barcode',
    component: Barcode,
    meta: { auth: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { auth: false }, 
    children: [
      {
        path: '/login/:type',
        name: 'Login',
        component: Login
      }
    ]
  },
  {
    path: "/:catchAll(.*)",
    name: '404',
    component: NotFound
  },

]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default (app) => {
  app.router = router;

  app.use(router);
}