<template>
<div class="container-md d-block mb-3">
  <ul class="list-group">
    <li class="checkout-header list-group-item py-3">
    
      <div class="row">
          <div class="col-auto col-select-box"  style="min-width:70px">
            <div class="d-grid h-100">
              <button class="no-border-radius btn btn-block h-100" v-if="anyRenewable" :class="{checked: checkedAll}" :aria-pressed="checkedAll" :disabled="checkAllDisabled()" :aria-label="$t('checkouts.selectAll')" type="button" @click="toggleCheckedAll()">
                <font-awesome-icon class="text-success" v-if="checkedAll" icon="check" size="2x"/>
                <font-awesome-icon v-else :icon="['far', 'square']" size="xs" />
              </button>
            </div>
          </div>
          <div class="col d-none d-xl-block">
            <div class="row">
              <div class="col-xl-4">
               {{$t('checkouts.title')}}
              </div>
              <div class="col-xl">
                {{$t('checkouts.author')}}
              </div>
              <div class="col-xl">
                {{$t('checkouts.due')}}
              </div>
              <div class="col-xl">
                {{$t('checkouts.renew')}}
              </div>
              <div class="col-xl">
                {{$t('checkouts.fine')}}
              </div>
            </div>
          </div>
          <div class="col d-xl-none">
            <span v-if="anyRenewable">{{$t('checkouts.selectAll')}}</span>
          </div>
      </div>
    </li> 
    <li class="list-group-item py-3" v-for="item in items" :key="item.itemnumber">
          <div v-if="item">
            <div class="row">
              <div class="col-auto col-select-box"  style="min-width:70px">
                <div class="d-grid h-100">
                  <button v-if="item.can_be_renewed" class="no-border-radius btn btn-block h-100" :class="{checked: itemChecked(item)}" :aria-pressed="itemChecked(item)" :aria-labelledby="'itemnumber-' + item.itemnumber" type="button" @click="checkBox(item)">
                      <font-awesome-icon class="text-success" v-if="itemChecked(item)" icon="check" size="2x"/>
                      <font-awesome-icon v-else :icon="['far', 'square']" size="xs" />
                  </button>
                </div>
              </div>
              <div class="col">
                <div class="row">
                  <div class="col-xl-4">
                    <div :id="'itemnumber-' + item.itemnumber"><span class="fw-bold">  <TitleLink :linkid="item.biblionumber">{{item.title}} </TitleLink></span> <span>({{item.barcode}}) </span> <span class="badge bg-secondary">{{$t('checkouts.loan_type.' + item.loan_type)}}</span> <span class="badge bg-secondary" v-if="item.onsite_checkout">{{$t('checkouts.loan_type.onsite_checkout')}}</span></div>
                  </div>
                  <div class="col-xl">
                    <div>{{item.author}} </div>
                  </div>
                  <div class="col-xl">
                    <div><span :class="{'text-danger': item.overdue}"><span>{{$t('checkouts.due')}}: </span> <span>{{item.date_due}}</span></span></div>
                  </div>
                  <div class="col-xl">
                      <RenewText :item="item" />
                  </div>
                  <div class="col-xl">
                    <div><span v-if="item.charges" class="d-xl-none">{{$t('checkouts.fine')}}:</span> {{finesText(item.charges)}}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
    </li>
  </ul>
</div>
</template>

<script>
import { useI18n } from 'vue-i18n'
import { ref } from 'vue'
import RenewText from './RenewText.vue';
import TitleLink from './TitleLink.vue';

export default {
  props: ['items', 'renewStatuses', 'anyRenewable'],
  emits: ['checked'],
  components: {
    RenewText,
    TitleLink
},
  setup(props, { emit }) {
    const i18n = useI18n({useScope: 'global'})
    const checkedItemIDs = ref([]);
    const checkedAll = ref(false);

    function toggleCheckedAll() {
      checkedAll.value = !checkedAll.value;
      toggleAllItems(checkedAll.value);
    }
    function toggleAllItems(checked) {
        checkedItemIDs.value = [];
        props.items.forEach(item => {
          if (item.can_be_renewed) {
            if (checked) {
              checkedItemIDs.value.push(item.itemnumber);
            }
            emit('checked', {itemnumber: item.itemnumber, state: checked ? "checked" : "unchecked"})
          }
          
        });
    }
    function itemChecked(item) {
        const found = checkedItemIDs.value.find(id => {
          if (item.itemnumber === id) {
            return true;
          }
          return false;
        })
        return found;
    }

    function checkAllDisabled() {
      const found = props.items.find(item => {
        return item.can_be_renewed === true;
      })
      return !found;
    }

    function checkBox(item) {
      if(item.can_be_renewed) {
        let itemIsChecked = null;
        const found = itemChecked(item);
        if (found) {
          const index = checkedItemIDs.value.indexOf(item.itemnumber);
          if (index > -1) {
            checkedItemIDs.value.splice(index, 1);
            itemIsChecked = false;
          }
        } 
        else {
            checkedItemIDs.value.push(item.itemnumber);
            itemIsChecked = true;
        }
        if (!checkedItemIDs.value.length) {
          checkedAll.value = false;
        }
        emit('checked', {itemnumber: item.itemnumber, state: itemIsChecked ? "checked" : "unchecked"})
      }
    }

    function finesText(finesValue) {
      if(finesValue > 0) {
        return `${finesValue} SEK`
      } else {
        return i18n.t('checkouts.noFine')
      }
    }

    function renewStatus(item) {
      if(item && props.renewStatuses) {
        const itemnumber = parseInt(item.itemnumber)
        const status = props.renewStatuses[itemnumber]
        if(status && status.status == "ok") {
          return {status: "bg-success", messageCode: "renewed_successful"}
        }
        if(status && status.status == "error") {
          return {status: "bg-danger", messageCode: "renew_error."+status.error}
        }
      }
      return false
    }

    return {
      itemChecked,
      finesText,
      renewStatus,
      checkBox,   
      checkedAll,
      toggleCheckedAll,
      checkAllDisabled
    }
  },
}
</script>

<style scoped>

.no-border-radius {
   border-radius: 0;
}

button:disabled {
  opacity: .3 !important;
}
.checkout-header {
   font-weight: bold;  
}

.col-select-box {
  padding:0;margin-top:-1rem;margin-bottom:-1rem;margin-left:-.3rem;min-width:70px;border-right:1px solid #ccc
}

</style>
