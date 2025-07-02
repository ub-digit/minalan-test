<template>
  <div v-if="setupComplete">
    <Nav v-if="setupComplete"/>

    <div class="container-md my-3">
      <router-view></router-view>
    </div>
  </div>
  <div v-if="!setupComplete">
    <Spinner class="mt-3"/>
  </div>
</template>

<script>
import Nav from '@/components/Nav.vue'
import Spinner from '@/components/Spinner.vue'
import { useAuth } from '@websanova/vue-auth'
import { useStore } from '@/pinia/store'
import { useI18n } from 'vue-i18n'
import { onBeforeMount } from 'vue'
import { watchEffect, watch } from 'vue'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useRoute } from 'vue-router'

export default {
  name: 'App',
  components: {
    Nav,
    Spinner
  },
  setup() {
    const auth = useAuth()
    const store = useStore()
    const i18n = useI18n()
    const setupComplete = ref(false)
    const router = useRouter()
    const route = useRoute()

    /* sets default application title while loading translations */
    i18n.setLocaleMessage('sv', {'application_title': 'Laddar...'});
    i18n.setLocaleMessage('en', {'application_title': 'Loading...'});
    document.title = i18n.t('application_title');

    onBeforeMount(async () => {
      await store.fetchSettings()
      const translations = await store.fetchTranslations()
      i18n.setLocaleMessage('en', translations.en)
      i18n.setLocaleMessage('sv', translations.sv)
      setupComplete.value = true
    })
    watchEffect(() => {
      if(auth.check()) {
        store.fetchPatronBrief(auth.$vm.state.data.login)
      } else {
        store.clearUser()
      }
    })
    watch(setupComplete, () => {
      document.title = i18n.t('application_title');
    })
    watch(i18n.locale, (newVal) => {
      document.title = i18n.t('application_title');
      const old_query = route.query;
      const query = {...old_query, ...{lang: newVal }};
      router.replace({query: query});
    })
    watch(route, () => {
      const old_query = route.query;
      const query = {...old_query, ...{lang: i18n.locale.value }};
      router.replace({query})
    })

    return {
      setupComplete
    }
  }
}
</script>

<style lang="scss">
body {
  background-image: url('/img/background-image.png');
}
</style>
