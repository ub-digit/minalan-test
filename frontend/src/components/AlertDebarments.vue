<template>
<div class="alert-debarments-wrapper">
  <div v-if="hasDebarment" class="container-md">
    <div class="alert alert-danger" >
      <div class="alert-debarments-header" v-html="$t('summary.debarments.header')"></div>
      <ul class="debarment-list">
        <li v-for="(debarment,index) in store.user.debarments" :key="index">
          <span v-html="$t(`summary.debarments.${debarment.type}`, {expiration_date: store.user.borrower.expire_date})"></span>
        </li>
      </ul>
      <div class="alert-debarments-footer" v-html="$t('summary.debarments.footer')"></div>
    </div>
  </div>
</div>
</template>

<script>
import { useStore } from '@/pinia/store'
import {computed} from 'vue'
export default {
  setup() {
    const store = useStore();
    return {
      store,
      hasDebarment: computed(() => {
        if (store.user && store.user.debarments && store.user.debarments.length) {  
          return true;
        }
        return false;
      })
    }
    
  }
}
</script>

<style lang="scss" scoped>

.alert-debarments-wrapper {

}

</style>
