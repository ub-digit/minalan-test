<template>
  <div class="container-md">
    <div class="alert alert-warning" v-if="message[$i18n.locale]" v-html="message[$i18n.locale]"></div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useIntervalFn } from '@vueuse/core'
import axios from 'axios'

export default {
  props: ['url', 'interval'],
  setup(props) {
    const interval = props.interval ? props.interval * 1000 : 60000
    const message = ref(fetchAlert(props.url))
    useIntervalFn(() => {
      fetchAlert(props.url)
    }, interval)

    async function fetchAlert(url) {
      try {
        let result = await axios.get(url)
        message.value = result.data
      } catch {
        message.value = {}
      }
    }

    return {
      message
    }
  },
}
</script>