<script lang="ts" setup>
import { useBaseStore, useBlockchain, useFormatter } from '@/stores';
import DynamicComponent from '@/components/dynamic/DynamicComponent.vue';
import { computed, ref } from '@vue/reactivity';
import type { Tx, TxResponse } from '@/types';

import { JsonViewer } from 'vue3-json-viewer';
// if you used v1.0.5 or latster ,you should add import "vue3-json-viewer/dist/vue3-json-viewer.css"
import 'vue3-json-viewer/dist/vue3-json-viewer.css';

const props = defineProps(['hash', 'chain']);

const blockchain = useBlockchain();
const baseStore = useBaseStore();
const format = useFormatter();
const tx = ref(
  {} as {
    tx: Tx;
    tx_response: TxResponse;
  }
);
if (props.hash) {
  blockchain.rpc.getTx(props.hash).then((x) => (tx.value = x));
}
const messages = computed(() => {
  return (
    tx.value.tx?.body?.messages.map((x) => {
      if (x.packet?.data) {
        // @ts-ignore
        x.message = format.base64ToString(x.packet.data);
      }
      return x;
    }) || []
  );
});

// Detect if this transaction contains a MsgEthereumTx
const hasEthereumTx = computed(() => {
  return messages.value.some((msg) => {
    const type = msg['@type'] || '';
    return type.includes('MsgEthereumTx');
  });
});

// Try to extract the EVM tx hash from events
const evmTxHash = computed(() => {
  const events = tx.value.tx_response?.events || [];
  for (const event of events) {
    if (event.type === 'ethereum_tx') {
      const hashAttr = event.attributes?.find(
        (attr: { key: string; value: string }) =>
          attr.key === 'ethereumTxHash' || attr.key === 'ethereum_tx_hash'
      );
      if (hashAttr?.value) {
        return hashAttr.value;
      }
    }
  }
  return null;
});

// Construct the EVM explorer URL
const evmExplorerUrl = computed(() => {
  if (evmTxHash.value) {
    return `https://evm-testnet.explorer.bitbadges.io/tx/${evmTxHash.value}`;
  }
  // Fall back to block page if we can't get the EVM tx hash
  const blockHeight = tx.value.tx_response?.height;
  if (blockHeight) {
    return `https://evm-testnet.explorer.bitbadges.io/block/${blockHeight}`;
  }
  return null;
});
</script>
<template>
  <div>
    <div class="tabs tabs-boxed bg-transparent mb-4">
      <RouterLink
        class="tab text-gray-400 uppercase"
        :to="`/${chain}/tx/?tab=recent`"
        >{{ $t('block.recent') }}</RouterLink
      >
      <RouterLink
        class="tab text-gray-400 uppercase"
        :to="`/${chain}/tx/?tab=search`"
        >Search</RouterLink
      >
      <a class="tab text-gray-400 uppercase tab-active">Transaction</a>
    </div>

    <div
      v-if="tx.tx_response"
      class="bg-base-100 px-4 pt-3 pb-4 rounded shadow mb-4"
    >
      <h2 class="card-title truncate mb-2">{{ $t('tx.title') }}</h2>
      <div class="overflow-hidden">
        <table class="table text-sm">
          <tbody>
            <tr>
              <td>{{ $t('tx.tx_hash') }}</td>
              <td class="overflow-hidden">{{ tx.tx_response.txhash }}</td>
            </tr>
            <tr>
              <td>{{ $t('account.height') }}</td>
              <td>
                <RouterLink
                  :to="`/${props.chain}/block/${tx.tx_response.height}`"
                  class="text-primary dark:invert"
                  >{{ tx.tx_response.height }}
                </RouterLink>
              </td>
            </tr>
            <tr>
              <td>{{ $t('staking.status') }}</td>
              <td>
                <span
                  class="text-xs truncate relative py-2 px-4 w-fit mr-2 rounded"
                  :class="`text-${tx.tx_response.code === 0 ? 'success' : 'error'}`"
                >
                  <span
                    class="inset-x-0 inset-y-0 opacity-10 absolute"
                    :class="`bg-${tx.tx_response.code === 0 ? 'success' : 'error'}`"
                  ></span>
                  {{ tx.tx_response.code === 0 ? 'Success' : 'Failed' }}
                </span>
                <span>
                  {{
                    tx.tx_response.code === 0 ? '' : tx?.tx_response?.raw_log
                  }}
                </span>
              </td>
            </tr>
            <tr>
              <td>{{ $t('account.time') }}</td>
              <td>
                {{ format.toLocaleDate(tx.tx_response.timestamp) }} ({{
                  format.toDay(tx.tx_response.timestamp, 'from')
                }})
              </td>
            </tr>
            <tr>
              <td>{{ $t('tx.gas') }}</td>
              <td>
                {{ tx.tx_response.gas_used }} / {{ tx.tx_response.gas_wanted }}
              </td>
            </tr>
            <tr>
              <td>{{ $t('tx.fee') }}</td>
              <td>
                {{
                  format.formatTokens(
                    tx.tx?.auth_info?.fee?.amount,
                    true,
                    '0,0.[00]'
                  )
                }}
              </td>
            </tr>
            <tr>
              <td>{{ $t('tx.memo') }}</td>
              <td>{{ tx.tx.body.memo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="hasEthereumTx && evmExplorerUrl" class="mt-4">
        <a
          :href="evmExplorerUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="btn btn-primary btn-sm"
        >
          View on EVM Explorer
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 ml-1"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
            />
          </svg>
        </a>
        <span v-if="!evmTxHash" class="text-xs text-gray-500 ml-2">
          (viewing block {{ tx.tx_response.height }})
        </span>
      </div>
    </div>

    <div
      v-if="tx.tx_response"
      class="bg-base-100 px-4 pt-3 pb-4 rounded shadow mb-4"
    >
      <h2 class="card-title truncate mb-2">
        {{ $t('account.messages') }}: ({{ messages.length }})
      </h2>
      <div v-for="(msg, i) in messages">
        <div class="border border-slate-400 rounded-md mt-4">
          <DynamicComponent :value="msg" />
        </div>
      </div>
      <div v-if="messages.length === 0">{{ $t('tx.no_messages') }}</div>
    </div>

    <div
      v-if="tx.tx_response"
      class="bg-base-100 px-4 pt-3 pb-4 rounded shadow"
    >
      <h2 class="card-title truncate mb-2">JSON</h2>
      <JsonViewer
        :value="tx"
        :theme="baseStore.theme"
        style="background: transparent"
        copyable
        boxed
        sort
        expand-depth="5"
      />
    </div>
  </div>
</template>
