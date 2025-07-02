<template>
<div class="navigation_wrapper">
  <div class="navbar navbar-dark bg-primary navbar-expand-xl">
    <div class="container-fluid">
      <div class="navbar-brand">
        <a :href="'http://www.ub.gu.se/' + $i18n.locale" :alt="$t('navbar.home')">
          <span class="logo"><img :src="'/img/gub-textlogo-'+$i18n.locale+'.svg'" :alt="$t('navbar.home')"></span>
        </a> |
        <router-link :to="{name: 'Checkouts'}" class="navbar-text text-decoration-none">{{$t('application_title')}}</router-link>
      </div>
      <button class="navbar-toggler" type="button" 
              data-bs-toggle="collapse" data-bs-target="#navbarNav"
              aria-controls="navbarNav" aria-expanded="false" :aria-label="$t('navbar.toggle')">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
          <li class="nav-item" v-if="$auth.$vm.state.authenticated">
            <router-link :to="{name: 'Checkouts'}" class="nav-link">{{$t('navbar.summary')}}</router-link>
          </li>
          <li class="nav-item" v-if="$auth.$vm.state.authenticated">
            <router-link :to="{name: 'Charges'}" class="nav-link">{{$t('navbar.charges')}}</router-link>
          </li>
          <li class="nav-item" v-if="$auth.$vm.state.authenticated">
            <router-link :to="{name: 'Details'}" class="nav-link">{{$t('navbar.details')}}</router-link>
          </li>
          <li class="nav-item" v-if="$auth.$vm.state.authenticated">
            <router-link :to="{name: 'Barcode'}" class="nav-link">{{$t('navbar.barcode')}}</router-link>
          </li>
        </ul>
        <ul class="navbar-nav ms-auto">
          <li class="nav-item dropdown" v-if="$auth.$vm.state.authenticated">
            <a class="nav-link  dropdown-toggle" href="#" id="navbarLoginMenuLink" :aria-label="$t('navbar.user')" role="button" data-bs-toggle="dropdown" aria-expanded="false">
              <span>{{$t('navbar.loginName')}}: {{$auth.$vm.state.data.name}}</span>
            </a>
            <ul class="dropdown-menu" aria-labelledby="navbarLoginMenuLink">
              <li class="text-md-center text-sm-start">
                <a class="dropdown-item" @click="$auth.logout()" href="#">{{ $t('navbar.logout') }}</a>
              </li>
            </ul>
          </li>
          <LocaleChanger/>
        </ul>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import LocaleChanger from '@/components/LocaleChanger.vue'

export default {
  components: {
    LocaleChanger
  },
  setup() {

  }
}
</script>

<style lang="scss" >
.navigation_wrapper {
  .navbar {
    margin-bottom: 20px;
    .nav-item {
      a {
        &:hover, &:focus {
            background-color: transparent;
        }
        &.router-link-active {
          background: transparent;
          border-bottom: 2px solid white;
        }
      }
    }
  }
}
</style>
