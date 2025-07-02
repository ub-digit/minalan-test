#!/bin/bash

echo 'Content-type: application/json'
echo 'Access-Control-Allow-Origin: *'
echo 'Access-Control-Allow-Headers: *'
echo ''
echo '{ '
echo -n '  "backend_url": "'"${MYLOANS_BACKEND_URL}"'"'
if test "x$MYLOANS_OAUTH2_CLIENT_ID" != "x"
then
  echo ','
  echo -n '  "oauth2": {'
  echo -n '    "client_id": "'"${MYLOANS_OAUTH2_CLIENT_ID}"'",'
  echo -n '    "redirect_uri": "'"${MYLOANS_OAUTH2_REDIRECT_URI}"'",'
  echo -n '    "scope": "'"${MYLOANS_OAUTH2_SCOPE}"'",'
  echo -n '    "authorize_endpoint": "'"${MYLOANS_OAUTH2_AUTHORIZE_ENDPOINT}"'"'
  echo -n '  }'
fi
if test "x$MYLOANS_NOTIFICATION_TIMEOUT" != "x"
then
  echo ','
  echo -n '  "notification_timeout": '"${MYLOANS_NOTIFICATION_TIMEOUT}"
fi
if test "x$MYLOANS_NOTIFICATION_PROGRESS_BAR" = "xtrue"
then
  echo ','
  echo -n '  "notification_progress_bar": true'
fi
if test "x$MYLOANS_NOTIFICATION_PROGRESS_BAR" = "xfalse"
then
  echo ','
  echo -n '  "notification_progress_bar": false'
fi
echo ''
echo '}'
