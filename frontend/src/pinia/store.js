import { defineStore } from 'pinia'
import { inject } from 'vue'
import axios from 'axios'

export const useStore = defineStore('store', {
  state: () => {
    return {
      user: null,
      baseURL: inject("baseURL"),
      settings: {},
      circulation: {
        checkouts: [],
        overdues: [],
        holds: []
      }
    }
  },
    getters: {
      anyRenewable: (state) => {
        return state.circulation.checkouts
          .filter(item => item.can_be_renewed)
          .length > 0
      },
      possibleToRenew: (state) => {
        return state.circulation.checkouts
          .filter(item => item.can_be_renewed)
          .map(item => item.itemnumber)
      },
      checkoutsByItemNumber: (state) => (itemnumbers) => {
        return state.circulation.checkouts
          .filter(item => itemnumbers.includes(item.itemnumber))
      }
    },
    actions: {
      async fetchPatronBrief(id) {
        try {
          let result = await axios.get(`${this.baseURL}/patrons/${id}?mode=brief`)
          this.user = result.data
          return result.data
        } catch (err) {
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            throw err.response.data.error
          }
          throw err
        }
      },
      async fetchSettings() {
        try {
          let result = await axios.get(`${this.baseURL}/setup/settings`)
          this.settings = result.data
          return result.data
        } catch (err) {
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            throw err.response.data.error
          }
          throw err
        }
      },
      async fetchPatronFull(id) {
        try {
          let result = await axios.get(`${this.baseURL}/patrons/${id}?mode=full`)
          this.user = {borrower: result.data.borrower, debarments: result.data.debarments, flags: result.data.flags}
          this.circulation = {checkouts: result.data.issues, overdues: result.data.overdues, holds: result.data.holds}
          return result.data
        } catch (err) {
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            throw err.response.data.error
          }
          throw err
        }
      },
      async fetchCharges(id) {
        try {
          let result = await axios.get(`${this.baseURL}/charges/${id}`)
          return result.data
        } catch (err) {
          console.log(err.message)
        }
      },
      async clearUser() {
        this.user = null
        this.circulation = {
          checkouts: [],
          overdues: [],
          holds: []
        }
      },
      async updatePatron({ id, userdata }) {
        try {
          let result = await axios.put(`${this.baseURL}/patrons/${id}`, { patron: userdata })
          console.log("🚀 ~ file: index.js ~ line 52 ~ updatePatron ~ result", result)
          this.fetchPatronBrief(id)
          return { status: "ok" }
        } catch (err) {
          if (err.response.status === 422) {
            return err.response.data
          }
          else if (err.response.data.error) {
            console.log('backend error', err.response, err)
            throw err.response.data.error
          }
          throw err
        }
      },
      async cancelReserve(reserve_id) {
        try {
          let cardnumber = this.user.borrower.cardnumber;
          let result = await axios.delete(`${this.baseURL}/reserves/${reserve_id}`)
          console.log("🚀 ~ file: index.js ~ line 98 ~ cancelReserve ~ result", result)
          this.fetchPatronFull(cardnumber)
          return {status: "ok"}
        } catch (err) {
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            throw err.response.data.error
          }
          else {
            throw err
          }
        }
      },
      async fetchTranslations() {
        let result = await axios.get(`${this.baseURL}/setup/translations`)
        return result.data
      },
      async renewItems({ id, itemnumbers }) {
        try {
          let result = await axios.post(`${this.baseURL}/renewals/${id}`, { itemnumbers: itemnumbers })
          await this.fetchPatronFull(id)
          return result.data
        }
        catch(err) {
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            throw err.response.data.error
          }
          else {
            throw err
          }
        }
      },
      async validatePassword(provided_password, provided_password_confirmation) {
        // Call the backend to check if the password is valid
        try {
          let result = await axios.post(`${this.baseURL}/password`, { password: provided_password, password2: provided_password_confirmation })
          return result.data
        }
        catch(err) {
          // 422 needs to be handled as a validation error like a successful request, not an error
          if (err.response.status === 422) {
            return err.response.data
          }
          if (err.response.data.error) {
            console.log(`backend error: ${ err.response.data.error}`, err)
            console.log(err.response.status)
            throw err.response.data.error
          }
          else {
            throw err
          }
        }
      }
    }
  })
