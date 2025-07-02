<template>
  <div class="container-md" v-if="items">
    <button 
      type="button"
      class="mx-1 btn btn-primary"
      :class='{"ub-btn-disabled": selected.length === 0}'
      @click="renewSelected"
      :disabled="selected.length === 0">{{$t('renewals.button.renew_selected', {count: selected.length})}}</button>
  </div>
</template>

<script>
import { useI18n } from 'vue-i18n'
import { useStore } from '@/pinia/store'
import { useMessage } from '@/plugins/message'

export default {
  props: ['items', 'selected'],
  emits: ['result'],

  setup(props, { emit }) {
    const store = useStore()
    const message = useMessage()
    const i18n = useI18n({ useScope: 'global' })

    async function renewItems(cardnumber, items) {
      try {
        var result = await store.renewItems({
          id: cardnumber,
          itemnumbers: items
        })
      } catch(err) {
        message.set('error', i18n.t('renewals.messages.unknown_error'))
        //TODO: emit some error state result on error?
        return
      }

      // @TODO: Find out possible status values
      let result_items = {
        'ok': [],
        'error': []
      }
      Object.values(result.statuses).forEach(function(item) {
        if (item['status'] === 'ok') {
          result_items.ok.push(item['itemnumber'])
        }
        else {
          result_items.error.push(item['itemnumber'])
        }
      })

      let titles = {};
      for (const item_status in result_items) {
        titles[item_status] = store.checkoutsByItemNumber(result_items[item_status])
          .map(item => item.title)
      }
      if (titles.ok.length) {
        message.setList('success', i18n.t('renewals.messages.renewal_ok'), titles.ok)
      }
      if (titles.error.length) {
        message.setList('error', i18n.t('renewals.messages.renewal_error'), titles.error)
      }
      emit('result', result)
    }

    async function renewSelected() {
      await renewItems(
        store.user.borrower.cardnumber,
        props.selected
      )
    }

    return {
      renewSelected
    }
  },
}
</script>

<style>
.ub-btn-disabled {
  background-color: lightgrey !important;
  border: 1px solid lightgrey !important;
  color: black !important;
}
</style>