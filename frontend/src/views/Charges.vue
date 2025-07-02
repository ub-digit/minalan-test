<template>
  <div class="container">
    <h1>{{ $t('charges.header')}}</h1>
  </div>
    <div v-if="store.user">
      <ChargesList :portal="data.portal" :charges="data.charges" :total="data.total" :payment_disabled="data.payment_disabled" v-if="data.charges !== null"/>
      <div v-if="data.charges === null">
        <Spinner />
      </div>
    </div>
</template>

<script>
import { reactive } from 'vue'
import ChargesList from '@/components/ChargesList.vue'
import Spinner from '@/components/Spinner.vue'
import { onMounted } from 'vue'
import { useStore } from '@/pinia/store'
import { useAuth } from '@websanova/vue-auth'

export default {
  components: {
    ChargesList,
    Spinner
  },
  setup() {
    const store = useStore()
    const auth = useAuth()

    const data = reactive({
      charges: null,
      portal: {},
      total: null
    })

    onMounted(async () =>  {
      const charges = await store.fetchCharges(auth.$vm.state.data.login)
      data.charges = charges.account_lines
      data.total = charges.total
      data.portal.callback_url = charges.callback_url
      data.portal.payment_portal_url = charges.payment_portal_url
      data.portal.uuid = charges.uuid
      data.payment_disabled = charges.payment_disabled
    })

    return {
      data,
      store
    }
  },
}
</script>