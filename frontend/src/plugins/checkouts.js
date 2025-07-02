import { ref } from 'vue'
import { useStore } from '@/pinia/store'
import { useAuth } from '@websanova/vue-auth'

function useCheckouts() {
  const store = useStore()
  const auth = useAuth()

  const checkedForRenew = ref([])
  const renewStatuses = ref(null)

  function checked({itemnumber, state}) {
    // If unchecked and in array, remove it
    // If checked and not in array, add it
    // ...otherwise leave it

    const pos = checkedForRenew.value.indexOf(itemnumber)
    if(pos != -1 && state != "checked") {
      checkedForRenew.value.splice(pos, 1)
    } else if(pos == -1 && state == "checked") {
      checkedForRenew.value.push(itemnumber)
    }
  }

  async function fetchSummaryData() {
    await store.fetchPatronFull(auth.$vm.state.data.login)
  }

  async function renewResult(statuses) {
    renewStatuses.value = (await statuses).statuses
    checkedForRenew.value = []
    await fetchSummaryData()
  }

  return {
    checked,
    renewResult,
    fetchSummaryData,
    checkedForRenew,
    renewStatuses
  }
}

export { useCheckouts }
