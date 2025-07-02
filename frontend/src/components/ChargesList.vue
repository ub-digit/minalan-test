<template>
<div class="container">
  <div class="alert alert-danger" v-if="payment_disabled" v-html="$t('charges.paymentDisabledMessage')"></div>
</div>
<div class="chargeslist-wrapper">
  <div v-if="charges.length !== 0">
    <div class="container-md d-block">
      <ul class="list-group mb-3">
        <li class="chargelist-header list-group-item py-3">
          <div class="row">
            <div class="col-auto col-select-box" style="min-width:70px">
              <div class="d-grid h-100">
                <button v-if="payable()" class="no-border-radius btn btn-block h-100" :class="{'checked': checkedAll}" :aria-label="$t('checkouts.selectAll')" :aria-pressed="checkedAll" type="button" @click="checkAllTop">
                     <font-awesome-icon class="text-success" v-if="checkedAll" icon="check" size="2x"/>
                     <font-awesome-icon v-else :icon="['far', 'square']" size="xs" />
                </button>
              </div>
            </div>
            <div class="col d-none d-xl-block fw-bold">
              <div class="row">
                <div class="col">
                  <div class="row">
                    <div class="col-xl-1" style="min-width:100px">
                      {{$t('charges.date')}}
                    </div>
                    <div class="col-xl">
                      {{$t('charges.type')}}
                    </div>
                    <div class="col-xl">
                      {{$t('charges.description')}}
                    </div>
                    <div class="col-xl-2">
                      {{$t('charges.amount')}}          
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col d-xl-none">
              <span class="fw-bold">{{$t('charges.total')}}: </span><span>{{total}} SEK</span>
              <p>
                <strong>{{$t('charges.sumSelected')}}:</strong> {{selectedSum}} SEK<br/>
                <span><strong>({{$t('charges.sumRemaining')}}: </strong> {{remainingSum}} SEK)</span>
              </p>
            </div>
          </div>
        </li>
        <li class="list-group-item py-3" v-for="charge in charges" :key="charge.accountlines_id">

          <div class="row" >
              <div class="col-auto col-select-box" style="min-width:70px">
                <div class="d-grid h-100">
                  <button v-if="payable(charge)" class="no-border-radius btn btn-block h-100" :class="{'checked':isChecked(charge)}" :aria-pressed="isChecked(charge)" :aria-labelledby="'accountlines_id-' + charge.accountlines_id" type="button" @click="checkBox(charge)">
                     <font-awesome-icon class="text-success" v-if="isChecked(charge)" icon="check" size="2x"/>
                     <font-awesome-icon  v-else :icon="['far', 'square']" size="xs" />
                  </button>
                  <button class="no-border-radius btn btn-block h-100" disabled aria-disabled="true" :aria-labelledby="'accountlines_id-' + charge.accountlines_id" type="button" v-else>
                    <font-awesome-icon class="text-danger"  icon="ban" size="lg"/>
                  </button>
                  
                </div>
              </div>
            <div class="col">
              <div :id="'accountlines_id-' + charge.accountlines_id" class="row">
                <div class="col-xl-1" style="min-width:100px">
                  <span>{{charge.date}}</span>
                </div>
                <div class="col-xl">
                  <span>{{$t('charges.types.'+charge.debit_type_code)}}  <span v-if="charge.status">({{$t('charges.status.'+charge.status)}})</span>: {{charge.date}}</span>
                </div>
                <div class="col-xl">
                  <div><strong>{{charge.description}}</strong></div>
                </div>
                <div class="col-xl-2">
                  <span class="d-xl-none"  >{{$t('charges.amount')}}: </span> <span>{{charge.amount}} SEK</span>
                </div>
              </div>
              
            </div>
          </div>
        </li>
      </ul>
      <div v-if="store.user.borrower.can_pay_online" class="mb-3">
        <div class="col-sm-10 col-md-9 col-lg-7 col-xl-6">
          <p>
            <span class="fw-bold">{{$t('charges.total')}}: </span><span>{{total}} SEK</span> <br/>
            <strong>{{$t('charges.sumSelected')}}:</strong> {{selectedSum}} SEK<br/>
            <span>({{$t('charges.sumRemaining')}}:  {{remainingSum}} SEK)</span>
          </p>
          <p>
            <span>{{$t('charges.paymentInformation')}}</span>
          </p>
        </div>
        <div class="alert alert-danger" v-if="payment_disabled" v-html="$t('charges.paymentDisabledMessage')"></div>
        <div v-if="!payment_disabled">
          <form method="post" :action="paymentPortalURL">
            <div class="form-group form-check mb-2">
              <input type="checkbox" class="form-check-input" id="accept_terms" name="accept_terms" v-model="acceptTerms" required>
              <label for="accept_terms" class="form-check-label">{{$t('charges.acceptTerms')}}</label>
            </div>
            <button class="btn btn-primary" :disabled="!acceptTerms || checkedCharges.length === 0" type="submit">{{$t('charges.pay')}}</button>
            <textarea class="payment-data" cols="100" name="payment_data" v-model="paymentData"></textarea>
          </form>
        </div>
      </div>
    </div>
  </div>
  <div class="container-md" v-if="charges.length === 0">
    <h4>{{ $t('charges.noCharges') }}</h4>
  </div>
  <div class="container-md" v-if="!canPayOnline()">
    <p>
      {{ $t('charges.paymentNotAllowed')}}
    </p>
  </div>
  <div class="container-md">
    <p>
      <a :href="$t('charges.moreInfoLink')" target="_blank">{{ $t('charges.moreInfoLinkText')}}</a>
    </p>
  </div>
</div>
</template>

<script>
import { ref } from 'vue'
import { computed } from 'vue'
import { watchEffect } from 'vue'
import { useStore } from '@/pinia/store'
import { buildPaymentObject, encodeLanguage } from '@/plugins/payment_object.js'

export default {
  props: ['portal', 'charges', 'total', 'payment_disabled'],
  setup(props) {
    const store = useStore()
    const acceptTerms = ref(false)
    const checked = ref({})
    const checkedAll = ref(payable())
    const checkedCharges = ref([])
    const initialized = ref(false)
    const paymentData = ref("")

    watchEffect(() => {
      if(!initialized.value) {
        fillPayable()
        initialized.value = true
      }
    })

    watchEffect(() => {
      if(checkedCharges.value.length == 0) {
        checkedAll.value = false
      }
    })

    function checkBox(charge) {
      if(payable(charge)) {
        toggleChecked(charge)
      }
    }

    function checkValue() {
      // Do nothing. This just prevents triggering checkBox
      // when clicking the actual input checkbox instead of
      // the whole list item
    }

    function toggleChecked(charge) {
      const position = checkedCharges.value.indexOf(charge.accountlines_id)
      if(position == -1) {
        checkedCharges.value.push(charge.accountlines_id)
      } else {
        checkedCharges.value.splice(position, 1)
      }
    }

    function isChecked(charge) {
      const position = checkedCharges.value.indexOf(charge.accountlines_id)
      if(position == -1) {
        return false;
      } 
      return true;
    } 

    function checkAllTop() {
      if(checkedAll.value) {
        clearChecked()
        checkedAll.value = false
      } else {
        fillPayable()
        checkedAll.value = true
      }
    }

    function checkAll() {
      if(checkedAll.value) {
        clearChecked()
      } else {
        fillPayable()
      }
    }

    function payable(charge) {
      if(store.user && !store.user.borrower.can_pay_online) {
        return false
      }
      if(!charge) { return true }
      return charge.payable
    }

    function  canPayOnline() {
      return store.user.borrower.can_pay_online;
    }


    watchEffect(() => {
      const payment_data = buildPaymentObject(props.portal, props.charges, checkedCharges)
      paymentData.value = JSON.stringify(payment_data)
    })

    const paymentPortalURL = computed(() => {
      return props.portal.payment_portal_url + '?language='+encodeLanguage()
    })

    const selectedSum = computed(() => {
      let sum = 0
      props.charges.forEach(charge => {
        if(checkedCharges.value.includes(charge.accountlines_id)) {
          sum += parseFloat(charge.amount)
        }
      })
      return sum
    })

    const remainingSum = computed(() => {
      let sum = 0
      props.charges.forEach(charge => {
        if(!checkedCharges.value.includes(charge.accountlines_id)) {
          sum += parseFloat(charge.amount)
        }
      })
      return sum
    })

    function fillPayable() {
      checkedCharges.value = []
      props.charges.forEach(charge => {
        if(payable(charge)) {
          checkedCharges.value.push(charge.accountlines_id)
        }
      });
    }

    function clearChecked() {
      checkedCharges.value = []
    }

    return {
      isChecked,
      payable,
      paymentData,
      paymentPortalURL,
      selectedSum,
      remainingSum,
      checked,
      checkedAll,
      checkBox,
      checkValue,
      checkAll,
      checkAllTop,
      checkedCharges,
      acceptTerms,
      store,
      canPayOnline
    }
  },
}
</script>

<style lang="scss" scoped>

.chargeslist-wrapper {
  .no-border-radius {
     border-radius: 0;
  }
  
  .col-select-box {
    padding:0;margin-top:-1rem;margin-bottom:-1rem;margin-left:-.3rem;min-width:70px;border-right:1px solid #ccc;
    
  }
  
  .payment-data {
    display: none
  }
}

</style>