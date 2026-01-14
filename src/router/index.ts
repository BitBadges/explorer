import { useBlockchain } from '@/stores';
import { createRouter, createWebHistory } from 'vue-router';
// @ts-ignore
import routes from '~pages';
import LayoutWrapper from '@/layouts/LayoutWrapper.vue';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: LayoutWrapper,
      children: routes
    }
  ],
});

//update current blockchain
router.beforeEach((to) => {
  const { chain } = to.params;
  if (chain) {
    const blockchain = useBlockchain();
    if (chain !== blockchain.chainName) {
      blockchain.setCurrent(chain.toString());
    }
  }
});

// Docs: https://router.vuejs.org/guide/advanced/navigation-guards.html#global-before-guards

export default router;
