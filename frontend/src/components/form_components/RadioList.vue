<template>
  <div>
    <fieldset :name="name">
      <div class="form-check form-check-inline" v-for="item in list" :key="item.value">
      <input @input="radioSelected(item.value)"
            type="radio"
            :id="name+'-'+item.value"
            :name="name"
            class="form-check-input"
            :checked="item.value == value"
            :value="value"/>
      <label :for="name+'-'+item.value" class="form-check-label me-1">{{$t(item.label_code)}}</label>
      </div>
    </fieldset>
  </div>
</template>

<script>
export default {
  props: ['list', 'value', 'name'],
  emits: ['change'],
  setup(props, { emit }) {
    function radioSelected(value) {
      emit('change', [props.name, value])
    }

    return {
      radioSelected
    }
  },
}
</script>