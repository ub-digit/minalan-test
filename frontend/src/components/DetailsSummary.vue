<template>
  <div>
    <div class="card mb-3">
      <div class="card-header fw-bold">{{$t('details.formHeader.identity')}}</div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item">
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.cardnumber')}}</div><div class="col">{{form.cardnumber}}</div>
          </div>
          <div class="row" v-if="form.pickup_code">
            <div class="col fw-bold">{{$t('details.form.pickupCode')}}</div><div class="col">{{form.pickup_code}}</div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.firstname')}}</div>
            <div class="col editable-inline-row" v-if="editMode">
              <Input :value="form.firstname" :error="errors.firstname" name="firstname" :skipLabel="true" @change="change"/>
            </div>
            <div class="col editable-inline-row" v-if="!editMode">
              <div class="col">{{form.firstname}}</div>
              <a href="#" class="edit-first-name-button" v-if="!editMode && form.can_change_firstname" @click="editMode = true">{{$t('details.form.firstnameEdit')}}</a>
            </div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.surname')}}</div><div class="col">{{form.surname}}</div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.expire_date')}}</div><div class="col">{{form.expire_date}}</div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.category')}}</div><div class="col">{{$t('details.category.' + form.categorycode)}}</div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.attributes.accept')}}</div><div class="col">{{$t('details.form.attributes.accept.value' + form.attributes.accept)}}</div>
          </div>
          <div class="row">
            <div class="col fw-bold">{{$t('details.form.attributes.pnr')}}</div><div class="col">{{form.attributes.pnr}}</div>
          </div>
          <div class="row">
            <a :href="$t('details.form.rules.url')" target="_blank">{{$t('details.form.rules.linkText')}}</a>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import Input from '@/components/form_components/Input.vue'
import { watchEffect } from 'vue'

export default {
  props: ['form', 'resetEditMode', 'errors'],
  emits: ['change', 'confirmResetEditMode'],
  components: {
    Input,
  },
  setup(props, { emit }) {
    const editMode = ref(false)

    watchEffect(() => {
      if (props.resetEditMode) {
        editMode.value = false
        // When reset has happened, emit a signal back to the parent to reset the resetEditMode prop
        emit('confirmResetEditMode')
      }
    })

    function change(updateData) {
      emit('change', updateData)
    }
    return {
      change,
      editMode,
    }
  },
}
</script>

<style>
  .editable-inline-row {
    display: inline-flex;
    justify-content: space-between;
    gap: 0.25rem;
  }

  .editable-inline-row > * {
    flex-basis: content;
    flex-shrink: 1;
    flex-grow: 0;
  }
</style>