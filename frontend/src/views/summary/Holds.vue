<template>
  <HoldsList :holds="store.circulation.holds"/>
</template>

<script>
import HoldsList from '@/components/HoldsList.vue'
import { useStore } from '@/pinia/store'

export default {
  components: {
    HoldsList
  },
  setup() {
    const store = useStore()
    return {
      store
    }
  },
}
</script>