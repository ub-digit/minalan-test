<template>
 <div class="checkouts-wrapper">
    <div v-if="store.circulation.checkouts.length">
      <CheckoutsList :items="store.circulation.checkouts" :renewStatuses="renewStatuses" :anyRenewable="store.anyRenewable" @checked="checked"/>
      <RenewButtons :items="store.possibleToRenew" :selected="checkedForRenew" @result="renewResult" v-if="store.anyRenewable"/>
    </div>
    <div class="container-md" v-else>
      <div class="row">
        <div class="col-auto mx-auto">
          <p class="checkouts-nothing-onloan">
            {{ $t('checkouts.nothingOnloan') }}
          </p>
        </div>
      </div>
    </div>
 </div>
</template>

<script>
import CheckoutsList from '@/components/CheckoutsList.vue'
import RenewButtons from '@/components/RenewButtons.vue'
import { useCheckouts } from '@/plugins/checkouts.js'
import { useStore } from '@/pinia/store'

export default {
  components: {
    CheckoutsList,
    RenewButtons
  },
  setup() {
    const {
      checked,
      checkedForRenew,
      renewResult,
      renewStatuses
    } = useCheckouts()

    const store = useStore()

    return {
      checked,
      checkedForRenew,
      renewResult,
      renewStatuses,
      store
    }
  },
}
</script>

<style lang="scss" scoped>
.checkouts-wrapper {
  .checkouts-nothing-onloan {
    margin-top: 20px;
  }
}

</style>
