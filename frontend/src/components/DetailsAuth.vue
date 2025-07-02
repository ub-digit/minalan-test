<template>
  <div>
    <div class="card mb-3">
      <div class="card-header fw-bold">{{$t('details.formHeader.authDetails')}}</div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item">
          <div class="row form_pin" v-if="form.has_local_pin">
            <Input :maxlength="4" :error="errors.pin" name="pin" :label="$t('details.form.pin')" :value="form.pin" @change="change" required="true"/>
          </div>
          <div class="row" v-if="!form.has_local_pin">
            <p v-html="$t('details.form.externalPinText')"></p>
            <p><a :href="$t('details.form.externalPinLinkUrl')" target="_blank">{{$t('details.form.externalPinLinkText')}}</a></p>
          </div>
        </li>
      </ul>
      <ul class="list-group list-group-flush" v-if="form.allow_password_change">
        <li class="list-group-item">
          <div class="row form_password" v-if="form.has_local_password">
            <Input :maxlength="16" :error="errors.password" name="password" :label="$t('details.form.password')" type="password" :value="form.password" @change="change"/>
          </div>
          <div class="row form_password" v-if="form.has_local_password">
            <Input :maxlength="16" :error="errors.password2" name="password2" :label="$t('details.form.password2')" type="password" :value="form.password2" @change="change"/>
          </div>
          <div class="row" v-if="!form.has_local_password">
            <p v-html="$t('details.form.externalPasswordText')"></p>
            <p><a :href="$t('details.form.externalPasswordLinkUrl')" target="_blank">{{$t('details.form.externalPasswordLinkText')}}</a></p>
          </div>
          <div class="row" v-if="form.has_local_password && password_touched">
            <p class="validation-intro">{{ $t('password_validation.intro') }}</p>
            <ul>
              <ValidationRow code="invalid_basic" :errors="password_validations"/>
              <ValidationRow code="require_upper" :errors="password_validations"/>
              <ValidationRow code="require_lower" :errors="password_validations"/>
              <ValidationRow code="require_digit" :errors="password_validations"/>
              <ValidationRow code="require_special" :errors="password_validations"/>
              <ValidationRow code="contains_invalid" :errors="password_validations"/>
              <ValidationRow code="dont_match" :errors="password2_validation"/>
            </ul>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import Input from '@/components/form_components/Input.vue'
import ValidationRow from '@/components/ValidationRow.vue'
import { useStore } from '@/pinia/store'
import { ref } from 'vue'

export default {
  props: ['form', 'errors'],
  emits: ['change'],
  components: {
    Input,
    ValidationRow
  },
  setup(props, { emit }) {
    const store = useStore()
    const password_validations = ref([])
    const password2_validation = ref([])
    const password_touched = ref(false)

    async function change(updateData) {
      emit('change', updateData)
      if (updateData[0] == "password" || updateData[0] == "password2") {
        password_touched.value = true
        let validation_status = await store.validatePassword(props.form.password || null, props.form.password2 || null)
        if(validation_status.status == "VALIDATION_ERROR") {
          // If validation_status.error has a key "password" or "password2", it means that the password is invalid
          // and we need to fill in "password_validations" or "password2_validation" with the error codes
          console.log("DetailsAuth-change", validation_status.error)
          if(validation_status.error.password) {
            password_validations.value = validation_status.error.password
          } else {
            password_validations.value = []
          }
          if(validation_status.error.password2) {
            password2_validation.value = [validation_status.error.password2]
          } else {
            password2_validation.value = []
          }
        } else {
          password_validations.value = []
          password2_validation.value = []
        }
      }
    }
    return {
      change,
      password_validations,
      password2_validation,
      password_touched
    }
  },
}
</script>

<style>
.form_pin input#pin {
  max-width: 4rem !important;
}
</style>