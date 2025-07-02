import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './locales'
import auth from '@/plugins/auth.js'
import http from '@/plugins/http.js'
import axios from 'axios'
import {useFontawesome} from '@/plugins/fontawesome.js'
import Toast from "vue-toastification";

import "./scss/custom.scss";

// Try to fetch backend url from cgi.
// If successful, use that url to read in configuration from backend
// ...otherwise default to env-variable with fallback to hardcoded elixir default
// Env-variable is only available during devel, but cgi will be accessible via
// docker container when running in a deployed environment

const local_url = '/cgi-bin/backend.cgi'
axios.get(local_url).then((result) => {
  return {
    baseURL: result.data.backend_url,
    notificationTimeout: result.data.notification_timeout,
    notificationProgressBar: result.data.notification_progress_bar,
    oauth2: {
      client_id: result.data.oauth2.client_id,
      redirect_uri: result.data.oauth2.redirect_uri,
      scope: result.data.oauth2.scope,
      authorize_endpoint: result.data.oauth2.authorize_endpoint
    }
  }
},() => {
  return {
    baseURL: process.env["VUE_APP_BACKEND_BASE_URL"] || "http://localhost:4000",
    notificationTimeout: 7000,
    notificationProgressBar: true,
    oauth2: {
      client_id: process.env["VUE_APP_OAUTH2_CLIENT_ID"],
      redirect_uri: process.env["VUE_APP_OAUTH2_REDIRECT_URI"],
      scope: process.env["VUE_APP_OAUTH2_SCOPE"],
      authorize_endpoint: process.env["VUE_APP_OAUTH2_AUTHORIZE_ENDPOINT"]
    }
  }
}).then((params) => {
  let app = createApp(App)
  const {FontAwesomeIcon} = useFontawesome();
  let notificationTimeout = params.notificationTimeout || 7000;
  let notificationProgressBar = params.notificationProgressBar
  if (notificationProgressBar == undefined || notificationProgressBar == null) {
    notificationProgressBar = true
  }
  app.baseURL = params.baseURL
  app.oauth2 = params.oauth2
  app
    .provide('baseURL', params.baseURL)
    .component("font-awesome-icon", FontAwesomeIcon)
    .use(router)
    .use(i18n)
    .use(createPinia())
    .use(http)
    .use(auth)
    .use(Toast, { timeout: notificationTimeout, position: 'top-center', transition: 'Vue-Toastification__fade', hideProgressBar: !notificationProgressBar })
    .mount('#app')
})

