<template>
<div class="container pickup-code-container" v-if="showPickupCode">
  <div class="row">
    <div class="col-12">
      <p>
        {{$t('holds.holds_to_pickup')}}<br/>
        <strong class="pickup-code">{{store.user.borrower.pickup_code}}</strong>
      </p>
    </div>
  </div>
</div>
<div class="container-md d-block d-lg-none">
  <ul class="list-group">
    <li class="list-group-item py-3" v-for="hold in holds" :key="hold.id">
      <button class="btn btn-danger text-nowrap float-end" v-if="hold.can_be_cancelled" :aria-label="$t('holds.cancel')" @click="cancel(hold.reserve_id)">{{$t('holds.cancel')}}</button>
      <div>
        <div class="fw-bold">{{hold.title}}</div>
        <div> {{$t('holds.statuses.'+hold.status, {library: $t('library.name.'+hold.branchcode), waitingdate: hold.waitingdate, expirationdate: hold.expirationdate})}}
          <span v-if="!hold.is_waiting">({{hold.reservedate}})</span>
        </div>
        <div>{{$t('holds.priority')}}: {{hold.priority}}</div>
      </div>
      <small v-if="hold.show_pickup_location"><i><span>{{$t('holds.pickup')}}: </span> <span>{{$t('library.name.'+hold.branchcode)}}</span></i></small>
      <small v-if="!hold.show_pickup_location"><i><span>{{$t('holds.send_home_text')}}</span></i></small>
    </li>
  </ul>
</div>
<div class="container d-none d-lg-block">
  <table class="table table-striped">
    <thead>
      <tr>
        <th>{{$t('holds.title')}}</th>
        <th>{{$t('holds.placedOn')}}</th>
        <th>{{$t('holds.pickup')}}</th>
        <th>{{$t('holds.priority')}}</th>
        <th>{{$t('holds.status')}}</th>
        <th>{{$t('holds.modify')}}</th>
      </tr>
    </thead>
    <tbody>
      <tr class="align-middle" v-for="hold in holds" :key="hold.reserve_id">
        <td><TitleLink :linkid="hold.biblionumber">{{hold.full_title}}</TitleLink></td>
        <td>{{hold.reservedate}}</td>
        <td>
          <span v-if="hold.show_pickup_location">{{$t('library.name.'+hold.branchcode)}}</span>
          <span v-if="!hold.show_pickup_location">{{$t('holds.send_home_text')}}</span>
        </td>
        <td>{{hold.priority}}</td>
        <td>{{$t('holds.statuses.'+hold.status, {library: $t('library.name.'+hold.branchcode), waitingdate: hold.waitingdate, expirationdate: hold.expirationdate})}}</td>
        <td><button class="btn btn-danger text-nowrap" v-if="hold.can_be_cancelled" @click="cancel(hold.reserve_id)">{{$t('holds.cancel')}}</button></td>
      </tr>
    </tbody>
  </table>
  </div>
</template>

<script>
import TitleLink from '@/components/TitleLink.vue'
import { useStore } from '@/pinia/store'
import { useI18n } from 'vue-i18n'
import { useMessage } from '@/plugins/message'
import { computed } from 'vue'

export default {
  props: ['holds'],
  components: {
    TitleLink
  },
  setup() {
    const store = useStore()
    const message = useMessage()
    const i18n = useI18n({ useScope: 'global' })

    const showPickupCode = computed(() => {
      // Return true if the user has a pickup code and has holds that are waiting
      if (store.user.borrower.pickup_code) {
        return store.circulation.holds.some(hold => hold.is_waiting)
      } else {
        return false
      }
    })

    async function cancel(reserve_id) {
      if(confirm(i18n.t('holds.cancel.confirm'))) {
        try {
          await store.cancelReserve(reserve_id)
        }
        catch (err) {
          message.set('error', i18n.t('holds.cancel.unknown_error'))
          throw err
        }
        message.set('success', i18n.t('holds.cancel.success'))
      }
    }

    return {
      cancel,
      store,
      showPickupCode
    }
  },
}
</script>

<style scoped>
.pickup-code {
  font-size: 1.5em;
}
.pickup-code-container {
  margin-top: 2em;
}
</style>
