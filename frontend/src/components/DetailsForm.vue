<template>
  <div class="card mb-3">
    <div class="card-header fw-bold">{{$t('details.formHeader.contactInformation')}}</div>
    <ul class="list-group list-group-flush">
      <li class="list-group-item">
        <div class="row">
          <Input class="col" :error="errors.phone" name="phone" :label="$t('details.form.phone')" :value="form.phone" @change="change"/>
        </div>
        <div class="row">
          <Input class="col" :error="errors.smsalertnumber" name="smsalertnumber" :label="$t('details.form.smsalertnumber')" :tip="$t('details.form.smsalertnumber.tip')" :value="form.smsalertnumber" @change="change"/>
        </div>
        <div class="row">
          <Input class="col" :error="errors.email" name="email" :label="$t('details.form.email')" :value="form.email" @change="change"/>
        </div>
      </li>
    </ul>
    <div class="card-header fw-bold">{{$t('details.formHeader.address')}}</div>
    <ul class="list-group list-group-flush">
      <li class="list-group-item">
        <div class="row">
          <Input class="col" :error="errors.address" name="address" :label="$t('details.form.address1')" :value="form.address" @change="change" :required="addressMandatory()"/>
        </div>
        <div class="row">
          <Input class="col" :error="errors.address2" name="address2" :label="$t('details.form.address2')" :value="form.address2" @change="change"/>
        </div>
        <div class="row">
          <Input class="col-sm-4" :error="errors.zipcode" name="zipcode" :label="$t('details.form.zip')" :value="form.zipcode" @change="change" :required="addressMandatory()"/>
          <Input class="col-sm-8" :error="errors.city" name="city" :label="$t('details.form.city')" :value="form.city" @change="change" :required="addressMandatory()"/>
        </div>
      </li>
    </ul>
    <div class="card-header fw-bold">{{$t('details.formHeader.alternateAddress')}}</div>
    <ul class="list-group list-group-flush">
      <li class="list-group-item">
        <div class="row">
          <Input class="col" :error="errors.b_address" name="b_address" :label="$t('details.form.altAddress1')" :value="form.b_address" @change="change"/>
        </div>
        <div class="row">
          <Input class="col" :error="errors.b_address2" name="b_address2" :label="$t('details.form.altAddress2')" :value="form.b_address2" @change="change"/>
        </div>
        <div class="row">
          <Input class="col-sm-4" :error="errors.b_zipcode" name="b_zipcode" :label="$t('details.form.altZip')" :value="form.b_zipcode" @change="change"/>
          <Input class="col-sm-8" :error="errors.b_city" name="b_city" :label="$t('details.form.altCity')" :value="form.b_city" @change="change"/>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
import Input from '@/components/form_components/Input.vue'
import { useStore } from '@/pinia/store'

export default {
  props: ['form', 'errors'],
  emits: ['change'],
  components: {
    Input
  },
  setup(_, { emit }) {
    const store = useStore()
    function addressMandatory() {
      return store.settings['address_mandatory'] === 'true'
    }

    function change(updateData) {
      emit('change', updateData)
    }
    return {
      change,
      addressMandatory
    }
  },
}
</script>