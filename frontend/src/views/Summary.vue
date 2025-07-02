<template>
  <div class="container">
    <h1>{{ $t('summary.header')}}</h1>
  </div>
  <Alert :url="store.settings.alert_url" interval="60"/>
  <AlertDebarments v-if="loaded" />
  <div v-if="loaded">
    <ul class="nav nav-tabs mx-3" id="summary-tabs">
      <li class="nav-item">
        <router-link :to="{name: 'Checkouts'}" class="nav-link">
          {{$t('summary.checkouts')}} ({{store.circulation.checkouts.length}})
        </router-link>
      </li> 
      <li class="nav-item" v-show="store.circulation.overdues.length">
        <router-link :to="{name: 'Overdues'}" class="nav-link">
          {{$t('summary.overdues')}} ({{store.circulation.overdues.length}})
        </router-link>
      </li> 
      <li class="nav-item" v-show="store.circulation.holds.length">
        <router-link :to="{name: 'Holds'}" class="nav-link">
          {{$t('summary.holds')}} ({{store.circulation.holds.length}})
        </router-link>
      </li> 
    </ul>
    <router-view></router-view>
  </div>
  <div v-else>
    <Spinner />
  </div>
</template>

<script>
import Alert from '@/components/Alert.vue'
import AlertDebarments from '@/components/AlertDebarments.vue'
import Spinner from '@/components/Spinner.vue'
import { ref } from 'vue'
import { onMounted } from 'vue'
import { useCheckouts } from '@/plugins/checkouts.js'
import { useStore } from '@/pinia/store'

export default {
  components: {
    Alert,
    AlertDebarments,
    Spinner
  },
  setup() {
    const { fetchSummaryData } = useCheckouts()
    const loaded = ref(false)
    const store = useStore()

    onMounted(async () =>  {
      await fetchSummaryData()
      loaded.value = true
    })

    return {
      loaded,
      store
    }
  },
}
</script>

<style scoped>
.router-link-exact-active {
  color: #f8f8f8 !important;
  background-color: #025da6 !important;
}
</style>