<script setup lang="ts">
import { onMounted, ref } from 'vue';

const STORAGE_KEY = 'bitbadges-cosmos-warning-shown';
const showNotification = ref(false);

onMounted(() => {
  // Check if notification has been shown before
  const hasBeenShown = localStorage.getItem(STORAGE_KEY);

  if (!hasBeenShown) {
    // Show notification on first load only
    showNotification.value = true;
  }
});

function confirmNotification() {
  // Store in localStorage that notification has been shown
  localStorage.setItem(STORAGE_KEY, 'true');
  showNotification.value = false;
}
</script>

<template>
  <input
    type="checkbox"
    v-model="showNotification"
    id="cosmos-warning-modal"
    class="modal-toggle"
  />
  <div class="modal" role="dialog">
    <div class="modal-box">
      <h3 class="font-bold text-lg mb-4">Cosmos-Based Explorer Notice</h3>
      <p class="py-4">
        In advanced cases, BitBadges supports multiple chains' wallets
        (Ethereum, Solana, Bitcoin, etc.) through mapping to equivalent
        BitBadges addresses. This explorer is Cosmos-based only. All addresses
        shown are the mapped equivalent Cosmos addresses.
      </p>
      <div class="modal-action">
        <button class="btn btn-primary" @click="confirmNotification">
          I Understand
        </button>
      </div>
    </div>
    <label
      class="modal-backdrop"
      for="cosmos-warning-modal"
      @click="confirmNotification"
    ></label>
  </div>
</template>
