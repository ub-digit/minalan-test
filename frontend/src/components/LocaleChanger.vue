<template>
  <li class="nav-item">
    <button class="btn nav-link" id="navbarLanguageToggle" :aria-label="$t('navbar.language.label')" @click="setLanguage($t('navbar.language.otherCode'))">
      <font-awesome-icon icon="globe" /> {{$t('navbar.language.otherName')}}
    </button>
  </li>
</template>

<script>
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

export default {
  setup() {
    const i18n = useI18n({ useScope: 'global' })
    const router = useRouter()

    function setLanguage(locale) {
      if(locale != i18n.locale.value) {
        router.replace({query: {lang: locale}})
      }
      i18n.locale.value = locale
    }

    return {
      setLanguage
    }
  },
}
</script>

<style lang="scss">
.dropdown ul.language-alternatives {
  left: inherit;
  right: 0;
}
</style>
