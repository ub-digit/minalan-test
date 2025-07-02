<template>
  <div class="mb-3">
    <label :for="name" :class="{'form-error': error}" class="form-label mb-1" v-if="!skipLabel">{{label}}</label>
    <span class="form-text required-text ms-1 fw-bold" v-if="required">{{$t('common.form.required_symbol')}}</span>
    <input @input="fieldChange($event.target.value)"
           :type="fieldType"
           :name="name"
           class="form-control"
           :class="{'form-error': error}"
           :id="inputId"
           :disabled="disabled"
           :checked="checked"
           :maxlength="maxlength"
           :value="value"/>
    <div class="form-text" v-if="tip">{{tip}}</div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  props: ['name', 'label', 'type', 'required', 'disabled', 'value', 'checked', 'id', 'error', 'maxlength', 'tip', 'skipLabel'],
  emits: ['change'],
  setup(props, { emit }) {
    const fieldType = ref(props.type || 'text')
    const inputId = ref(props.id || props.name)

    function fieldChange(new_value) {
      emit('change', [props.name, new_value])
    }

    return {
      fieldType,
      inputId,
      fieldChange
    }
  },
}
</script>

<style scoped>
.required-text {
  color: red;
}

.form-error {
  color: red;
}

input.form-error {
  border-color: red;
}
</style>