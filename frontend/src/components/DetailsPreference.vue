<template>
  <div>
    <div class="card mb-3">
      <div class="card-header fw-bold">{{$t('details.formHeader.messagePreference')}}</div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item">
          <div class="row mb-3">
            <RadioList name="message_preference" :list="list" :value="form.message_preference" @change="change"/>
          </div>
          <div class="row">
            <!-- Selector for message language (sv-SE/en) in a select element -->
            <div class="col-12 col-md-6">
              <!-- Inline form group, one single line -->
              <div class="form-group">
                <label for="message_language" class="form-label">{{$t('details.form.messageLanguage')}}</label>
                <select id="message_language" class="form-select" name="lang" :value="form.lang" @change="change(['lang', $event.target.value])">
                  <option value="sv-SE" :selected="form.lang == 'sv-SE'">{{$t('details.form.messageLanguage.sv-SE')}}</option>
                  <option value="en" :selected="form.lang == 'en'">{{$t('details.form.messageLanguage.en')}}</option>
                </select>
              </div>
            </div>
          </div>
        </li>
      </ul>
    </div>
    <div class="card mb-3" v-if="form.allow_survey_acceptance">
      <div class="card-header fw-bold">{{$t('details.formHeader.surveyAcceptance')}}</div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item">
          <div class="row mb-3">
            <RadioList name="survey_acceptance" :list="survey_choices" :value="form.survey_acceptance" @change="change"/>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import RadioList from '@/components/form_components/RadioList.vue'
import { reactive } from 'vue'

export default {
  props: ['form'],
  emits: ['change'],
  components: {
    RadioList
  },
  setup(_, { emit }) {
    function change(formData) {
      emit('change', formData)
    }

    const list = reactive([
      {value: "email", label_code: "details.form.messagePreference.email"},
      {value: "sms", label_code: "details.form.messagePreference.SMS"},
      {value: "email_sms", label_code: "details.form.messagePreference.emailSMS"}
    ])

    const survey_choices = reactive([
      {value: "yes", label_code: "details.form.surveyAcceptance.yes"},
      {value: "no", label_code: "details.form.surveyAcceptance.no"}
    ])

    return {
      change,
      list,
      survey_choices
    }
  },
}
</script>