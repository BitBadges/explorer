<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import DefaultLayout from './default.vue';
import BlankLayout from './blank.vue';

const route = useRoute();
const layout = computed(() => route.meta?.layout || 'default');
</script>

<template>
  <DefaultLayout v-if="layout === 'default'" />
  <BlankLayout v-else>
    <RouterView />
  </BlankLayout>
</template>
