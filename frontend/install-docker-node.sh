#!/bin/bash

. ../backend/.env.local

docker run --rm -it -v ./:/home/node/app \
--net host \
--name vue-app \
-e VUE_APP_OAUTH2_AUTHORIZE_ENDPOINT="$OAUTH2_AUTHORIZE_ENDPOINT" \
-e VUE_APP_OAUTH2_TOKEN_ENDPOINT="$OAUTH2_TOKEN_ENDPOINT" \
-e VUE_APP_OAUTH2_USER_ENDPOINT="$OAUTH2_USER_ENDPOINT" \
-e VUE_APP_OAUTH2_CLIENT_ID="$OAUTH2_CLIENT_ID" \
-e VUE_APP_OAUTH2_SCOPE="$OAUTH2_SCOPE" \
-e VUE_APP_OAUTH2_REDIRECT_URI="$OAUTH2_REDIRECT_URI" \
-w /home/node/app node:16-bullseye npm install
