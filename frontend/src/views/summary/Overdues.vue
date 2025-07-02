<template>
  <CheckoutsList :items="store.circulation.overdues" :renewStatuses="renewStatuses" :anyRenewable="store.anyRenewable" @checked="checked"/>
  <RenewButtons :items="store.possibleToRenew" :selected="checkedForRenew" @result="renewResult" v-if="store.anyRenewable"/>
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
    const {checked, checkedForRenew, renewResult, renewStatuses } = useCheckouts()
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
