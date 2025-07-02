import { i18n } from '@/locales'

const { t } = i18n.global

function buildPaymentObject(portal, charges, checkedCharges) {
  let checked = []
  charges.forEach(charge => {
    if(checkedCharges.value.includes(charge.accountlines_id)) {
      checked.push(charge)
    }
  })

  return {
    callback_url: portal.callback_url,
    return_url: returnURL(),
    uid: portal.uuid,
    language: encodeLanguage(),
    payments: buildPayments(checked)
  }
}

function buildPayments(payments) {
  return payments.map(payment => buildPayment(payment))
}

function buildPayment(payment) {
  return {
    account_id: parseInt(payment.accountlines_id),
    amount: parseFloat(payment.amount),
    library_group: payment.library_group,
    debit_type: payment.debit_type,
    debit_title: t('charges.types.'+payment.debit_type_code),
    text: payment.barcode || "",
    title: payment.title || ""
  }
}

function returnURL() {
  return window.location.origin + window.location.pathname + '?lang=' + i18n.global.locale
}

function encodeLanguage() {
  if(i18n.global.locale == "en") {
    return "en-US"
  }
  return "sv-SE"
}

export {
  buildPaymentObject,
  encodeLanguage
}