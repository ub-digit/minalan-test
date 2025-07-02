<template>
  <a :href="titleUrl()" target="_blank" v-if="isLinked">
    <slot></slot>
  </a>
  <span v-if="!isLinked"><slot></slot></span>
</template>

<script>
import { useStore } from '@/pinia/store'
import { useI18n } from 'vue-i18n'
import { ref } from 'vue'
import { onMounted } from 'vue'

export default {
  props: ['linkid'],
  setup(props) {
    const i18n = useI18n()
    const store = useStore()
    const isLinked = ref(false)

    function titleUrl() {
      const base_url = store.settings['external_title_url_' + i18n.locale.value]
      if(!base_url) return undefined
      return base_url.replace("%BIBID%", props.linkid)
    }

    onMounted(() => {
      isLinked.value = !!store.settings['external_title_url_' + i18n.locale.value]
    })

    return {
      titleUrl,
      isLinked
    }
  },
}
</script>