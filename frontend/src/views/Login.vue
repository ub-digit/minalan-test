<template>
<div class="login-wrapper">
  <div class="container">
    <div v-if="state.form.code || state.validating" class="spinner">Loading login...</div>
    <div v-else>
      <Alert :url="store.settings.alert_url" interval="60"/>
      <div class="cas-login" v-if="store.settings.sso_provider === 'cas'">
        <div class="row justify-content-center">
          <div class="col col-md-8 col-lg-4">
            <a :href="casLoginURL()" alt="Link to CAS-login">
            <div class="card">
              <div class="card-body">
                    <div class="logo mb-2"><img :src="'/img/gu-logo-login-gu-account@2x-'+$i18n.locale+'.png'" alt="logotype"></div> 
                    <div class="login-header mb-2">{{$t('login.casHeader')}} </div>
                    <p class="card-text"> {{ $t('login.casDescription')}}</p>
                    <div v-if="state.form.errorCAS" class="alert alert-danger" role="alert">
                      {{$t("login.casErrorLoginMsg")}}
                    </div>
              </div>
            </div>
            </a>
          </div>
        </div>
      </div>
      <div class="github-login" v-if="store.settings.sso_provider === 'github'">
        <div class="row justify-content-center">
          <div class="col col-md-8 col-lg-4">
            <a :href="store.settings.oauth2_authorize_endpoint" alt="Link to Github-login" @click.prevent="oauth2Default('github')">
            <div class="card">
              <div class="card-body">
                    <div class="logo mb-2"><img :src="'/img/gu-logo-login-gu-account@2x-'+$i18n.locale+'.png'" alt="logotype"></div>
                    <div class="login-header mb-2">{{$t('login.github.header')}} </div>
                    <p class="card-text"> {{ $t('login.github.description')}}</p>
                    <div v-if="state.form.errorOauth2" class="alert alert-danger" role="alert">
                      {{$t("login.github.errorLoginMsg")}}
                    </div>
              </div>
            </div>
            </a>
          </div>
        </div>
      </div>
      <div class="GU-login" v-if="store.settings.sso_provider === 'GU'">
        <div class="row justify-content-center">
          <div class="col col-md-8 col-lg-4">
            <a :href="store.settings.oauth2_authorize_endpoint" alt="Link to GU-login" @click.prevent="oauth2Default('GU')">
            <div class="card">
              <div class="card-body">
                    <div class="logo mb-2"><img :src="'/img/gu-logo-login-gu-account@2x-'+$i18n.locale+'.png'" alt="logotype"></div>
                    <div class="login-header mb-2">{{$t('login.GU.header')}} </div>
                    <p class="card-text"> {{ $t('login.GU.description')}}</p>
                    <div v-if="state.form.errorOauth2" class="alert alert-danger" role="alert">
                      {{$t("login.GU.errorLoginMsg")}}
                    </div>
              </div>
            </div>
            </a>
          </div>
        </div>
      </div>

      
      <div class="row justify-content-center mb-3" v-if="store.settings.sso_provider !== 'none'">
          <div class="col-md-8 col-lg-4">
            <div class="m-3 divider text-center">
             <span class="text px-2">{{ $t('login.dividerText')}}</span>
            </div>  
          </div>
      </div>

      <div class="koha-login">
        <div class="row justify-content-center">
          <div class="col col-md-8 col-lg-4">
              <div class="login-header mb-3">{{ $t("login.form.kohaHeader")}}</div>
              <p class="mb-5"> {{ $t("login.form.kohaDescription")}} </p>
              <div v-if="state.form.errorKoha" class="alert alert-danger" role="alert">
                {{$t("login.form.kohaErrorLoginMsg")}}
              </div>
              <form class="d-grid gap-3" @submit.prevent="sendLogin">
                <div>
                  <label class="form-label" for="cardnumber">{{$t('login.form.cardnumber')}}</label>
                  <input type="text" class="form-control" id="cardnumber" name="cardnumber" v-model="state.form.data.cardnumber" />
                </div>
                <div>
                  <label class="form-label" for="password">{{$t('login.form.password')}}</label>
                  <input type="password" class="form-control" id="password" name="password" v-model="state.form.data.password" />
                </div>
                <div class="d-grid">
                  <button type="submit" class="btn btn-primary">{{$t('login.form.submit')}}</button>
                </div>
                <div class="getaccount text-center"><a :href="$t('login.getLibrarycard.url')">{{ $t("login.getLibrarycard.linktext")}}</a></div>
                <div class="resetpassword text-center"><a :href="$t('login.resetPassword.url')" target="_BLANK">{{ $t("login.resetPassword.linktext")}}</a></div>
              </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import { watch } from "vue";
import { reactive } from "vue";
import { onMounted } from "vue";
import { useRoute } from "vue-router";
import { useStore } from "@/pinia/store";
import { useAuth } from "@websanova/vue-auth/src/v3.js";
import { useI18n } from 'vue-i18n';
import Alert from "@/components/Alert.vue";
export default {
  components: {
    Alert,
  },
  setup() {
    const auth = useAuth();
    const route = useRoute();
    const store = useStore();
    const i18n = useI18n();
    const state = reactive({
      validating: false,
      form: {
        error: false,
        body: {},
        data: {},
        code: false,
        params: {
          state: {
            remember: false,
            staySignedIn: true,
            fetchUser: false,
          },
        },
      },
    });
    watch(() => {
      return route.params.type;
    }, reset);
    onMounted(() => {
      reset();
      if (route.params.type == "cas") {
        authCAS()
      } else if (state.form.code) {
        oauth2Default(route.params.type);
      }
    });
    function reset() {
      delete state.form.url;
      delete state.form.state;
      state.form.body = {};
      state.form.data = {};
      state.form.code = route.query.code ? true : false;
      if (state.form.code) {
        state.form.url = `${store.baseURL}/auth/${route.params.type}`;
        state.form.state = route.query.state;
        state.form.data.code = route.query.code;
      }
    }
    async function oauth2Default(type) {
      try {
        await auth.oauth2(type, state.form);
      } catch (_) {
        state.form.errorOauth2 = true;
        state.form.code = false;
        delete state.form.url;
      }
    }

    async function sendLogin() {
      state.form.data.provider = "koha";
      try {
        await auth.login({
          data: state.form.data,
          remember: state.form.remember ? '{"name": "Default"}' : null,
          fetchUser: false,
          staySignedIn: true,
          redirect: "/",
        });
      } catch (_) {
        state.form.errorKoha = true;
      }
    }

    function casLoginURL() {
      const serviceURL = casServiceURL()
      return store.settings.cas_login_url + "?service=" + encodeURIComponent(serviceURL)
    }

    function casServiceURL() {
      const lang = i18n.locale.value
      return location.origin + auth.drivers.cas.servicePath + "?lang=" + encodeURIComponent(lang)
    }

    async function authCAS() {
      const url = store.baseURL + auth.drivers.cas.validationPath
      state.validating = true
      state.form.errorCAS = false
      try {
        await auth.login({
          url: url,
          data: {
            ticket: route.query.ticket,
            service: casServiceURL(),
          },
          redirect: "/"
        })
      } catch(_) {
        state.form.errorCAS = true
      }
      state.validating = false
    }

    return {
      state,
      store,
      oauth2Default,
      sendLogin,
      casLoginURL,
    };
  },
};
</script>

<style lang="scss" scoped>
.login-wrapper {
  .cas-login,.github-login,.GU-login {
    a {
      .logo {
        img {
          width: 193px;
          height: 30;
        }
      }
      color: black;
      text-decoration: none;
      &:hover {
        text-decoration: underline;
      }
      .card {
  
        text-decoration: none;
        .login-header {
          text-decoration: none;
        }
      }
    }
  }
  .login-header {
    font-size: 1.3rem;
    font-weight: 700;
  }
  .divider {
    font-size: 1rem;
    color: #767676;
    border-bottom: 2px solid #767676;
    margin-top: 10px;
    .text {
      font-weight: 700;
      position: relative;
      top: 12px;
      background-color: white;
    }
  }
  .error {
    border: 1px solid red;
    display: inline-block;
    padding: 5px;
    padding-top: 5px;
    margin-top: 10px;
    border-radius: 5px;
    padding-top: 7px;
    background-color: #f99;
    font-weight: bold;
    width: 20em;
  }
}


</style>
