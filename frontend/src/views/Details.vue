<template>
  <form class="form-floating" @submit.prevent="updatePatron">
    <div class="container">
      <div class="row header-row">
        <h1>{{$t('details.header')}}</h1>
        <div class="button-at-top">
          <button type="submit" class="btn btn-primary">{{$t('details.update')}}</button>
        </div>
      </div>
      <div class="alert alert-success alert-dismissible show" aria-atomic="true" v-if="saveSuccess" role="alert">
        {{ $t('details.save.success') }}
        <button type="button" class="btn-close" @click.prevent="dismiss" aria-label="Close"></button>
      </div>

    </div>
    <div class="container">
      <div class="d-flex row" v-if="data.form">
        <div class="col-4 offset-8 fixed-bottom">
          <div class="card">
            <div class="card-header fw-bold" style="display:none" @click="toggleDebug">DEBUG</div>
            <ul class="list-group list-group-flush" v-if="debugVisible">
              <li class="list-group-item">
                {{data.form}}
              </li>
            </ul>
          </div>
        </div>
        <div class="col-xl-5 col-lg-5 order-lg-2 order-xl-2 order-sm-1 order-xs-1 order-md-1">
          <DetailsSummary :form="data.form" :errors="errors" @change="change" @confirmResetEditMode="confirmResetEditMode" :resetEditMode="resetEditMode" />
          <DetailsPreference :form="data.form" @change="change" />
          <DetailsAuth :form="data.form" :errors="errors" @change="change" />
        </div>
        <div class="col-xl-7 col-lg-7 col-md-12 col-sm-12 order-lg-1 order-xl-1 order-sm-2 order-xs-2 order-md-2">
          <DetailsForm :form="data.form" :errors="errors" @change="change" />
          <button type="submit" class="btn btn-primary">{{$t('details.update')}}</button>
        </div>
      </div>
    </div>
  </form>
</template>

<script>
import DetailsForm from '@/components/DetailsForm.vue'
import DetailsSummary from '@/components/DetailsSummary.vue'
import DetailsPreference from '@/components/DetailsPreference.vue'
import DetailsAuth from '@/components/DetailsAuth.vue'
import { reactive, ref } from 'vue'
import { watchEffect } from 'vue'
import { useStore } from '@/pinia/store'
import { useAuth } from '@websanova/vue-auth'
import { useMessage } from '@/plugins/message'
import { useI18n } from 'vue-i18n'

export default {
  components: {
    DetailsForm,
    DetailsSummary,
    DetailsPreference,
    DetailsAuth
  },
  setup() {
    const store = useStore()
    const auth = useAuth()
    const message = useMessage()
    const i18n = useI18n({ useScope: 'global' })

    const data = reactive({
      form: null
    })

    const resetEditMode = ref(false)

    const debugVisible = ref(false);

    const errors = ref({})

    watchEffect(async () => {
      if(store.user) {
        data.form = store.user.borrower
      }
    })

    function change([name, value]) {
      data.form[name] = value
    }

    function confirmResetEditMode() {
      resetEditMode.value = false
    }

    async function updatePatron() {
      try {
        var result = await store.updatePatron({ id: auth.$vm.state.data.login, userdata: data.form })
      } catch (err) {
        message.set('error', i18n.t('details.update.unknown_error'))
        throw err
      }
      if (result.error && result.error == 'VALIDATION_ERROR') {
        message.set('warning', i18n.t('details.update.validation_error'))
        errors.value = result.validation_data
      }
      else {
        message.set('success', i18n.t('details.update.success'))
        resetEditMode.value = true
        errors.value = {}
      }
    }

    function toggleDebug() {
      debugVisible.value = !debugVisible.value
    }

    return {
      updatePatron,
      change,
      toggleDebug,
      debugVisible,
      resetEditMode,
      confirmResetEditMode,
      data,
      errors
    }
  },
}
</script>

<style>
  .header-row {
    display: flex;
    justify-content: space-between;
  }

  .header-row > * {
    flex-shrink: 1;
    flex-grow: 0;
    flex-basis: content;
  }
</style>