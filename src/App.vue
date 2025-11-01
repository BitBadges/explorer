<script setup lang="ts">
import { themeChange } from 'theme-change';
import { onMounted } from 'vue';
import TxDialog from './components/TxDialog.vue';
import CosmosWarningNotification from './components/CosmosWarningNotification.vue';

onMounted(() => {
  themeChange(false);
});
</script>

<template>
  <div>
    <RouterView />
    <TxDialog />
    <CosmosWarningNotification />
  </div>
</template>
