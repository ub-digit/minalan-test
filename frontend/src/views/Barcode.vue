<template>
  <h1>{{ $t('barcode.header') }}</h1>
  <div class="row">
    <p>{{ $t('barcode.infotext') }}</p>
  </div>
  <div class="row d-flex justify-content-center">
    <div class="col"></div>
    <div class="col flex-grow-0" v-if="store.user">
      <div class="card text-center">
        <BarcodeGenerator :value="store.user.borrower.cardnumber" format="code128"/>
      </div>
    </div>
    <div class="col"></div>
  </div>
</template>

<script>
import BarcodeGenerator from '@/components/BarcodeGenerator.vue';
import { useStore } from '@/pinia/store'

export default {
  components: {
    BarcodeGenerator
  },
  setup() {
    const store = useStore()

    return {
      store
    }
  },
}
</script>