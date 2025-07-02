<template>
<div>
  <div v-if="!item.can_be_renewed">                          
      <div v-if="item.renew_status.reason === 'auto_too_soon' || item.renew_status.reason === 'auto_renew'">
        {{ $t('renewals.reason.auto_renew')}} ({{$t('renewals.renew_count', {left: item.renewsleft, max: item.renewsallowed})}})
      </div>
      <div v-if="item.renew_status.reason === 'item_lost'">
        {{ $t('renewals.reason.item_lost')}}
      </div>
      <div v-if="item.renew_status.reason === 'on_reserve'">
        {{ $t('renewals.reason.on_reserve')}}
      </div>
      <div v-if="item.renew_status.reason === 'too_many'">
        {{ $t('renewals.reason.too_many')}}
      </div>
      <div v-if="item.renew_status.reason === 'no_renew_overdue'">
        {{ $t('renewals.reason.no_renew_overdue')}}
      </div>
      <div v-if="item.renew_status.reason === 'no_renewals_available'">
        {{ $t('renewals.reason.no_renewals_available')}}
      </div>
      <div v-if="item.renew_status.reason === 'no_renewals_left'">
        {{ $t('renewals.reason.no_renewals_left')}}
      </div>
      <div v-if="item.renew_status.reason === 'no_renew_overdue'">
        {{ $t('renewals.reason.no_renew_overdue')}}
      </div>
      <div v-if="item.renew_status.reason === 'auto_too_late'">
        {{ $t('renewals.reason.auto_too_late')}}
      </div>
      <div v-if="item.renew_status.reason === 'auto_too_much_oweing'">
        {{ $t('renewals.reason.auto_too_much_oweing')}}
      </div>
      <div v-if="item.renew_status.reason === 'too_much_oweing'">
        {{ $t('renewals.reason.too_much_oweing')}}
      </div>
      <div v-if="item.renew_status.reason === 'auto_account_expired'">
        {{ $t('renewals.reason.auto_account_expired')}}
      </div>
      <div v-if="item.renew_status.reason === 'account_expired'">
        {{ $t('renewals.reason.account_expired')}}
      </div>
      <div v-if="item.renew_status.reason === 'too_soon'">
        {{ $t('renewals.reason.too_soon', {date: item.renew_status.timestamp})}}
        ({{$t('renewals.renew_count', {left: item.renewsleft, max: item.renewsallowed})}})
      </div>
    </div>
    <div v-else>
      {{$t('renewals.renew_count', {left: item.renewsleft, max: item.renewsallowed})}}
    </div>
    <span class="badge bg-secondary" v-if="item.recently_renewed">{{ $t('renewals.recently_renewed')}}</span>
</div>
</template>

<script>

export default {
  props: ['item'],
  setup() {
    return {
      
    }
  }
}
</script>