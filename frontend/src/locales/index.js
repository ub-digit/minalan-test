import { createI18n } from 'vue-i18n'
import { en } from '@/locales/en.js'
import { sv } from '@/locales/sv.js'

const messages = {
    en: en,
    sv: sv
}

let url = new URL(window.location.href)
let url_lang = url.searchParams.get('lang')
let browser_langs = navigator.languages ? navigator.languages[0]: undefined;
let browser_lang = navigator.language;
let selected_browser_lang = browser_langs || browser_lang;

if (selected_browser_lang && (selected_browser_lang.substring(0,2) == "sv" )) {
    selected_browser_lang = "sv"
} else {
    selected_browser_lang = "en";
}


const i18n = createI18n({
    locale: url_lang || selected_browser_lang || 'sv',
    fallbackLocale: 'en',
    messages
})

export { i18n }