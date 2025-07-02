FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1

FROM node:16-bullseye AS build

WORKDIR /root

COPY --from=release /root/release/frontend ./

RUN set -ex \
 && npm install \
 && npm run build

FROM httpd:2.4-bullseye
ENV TZ=Europe/Stockholm
RUN sed -i 's/#\(LoadModule cgid_module modules\/mod_cgid.so\)/\1/' /usr/local/apache2/conf/httpd.conf
RUN echo 'FallbackResource /' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_BACKEND_URL' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_NOTIFICATION_TIMEOUT' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_NOTIFICATION_PROGRESS_BAR' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_OAUTH2_CLIENT_ID' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_OAUTH2_AUTHORIZE_ENDPOINT' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_OAUTH2_REDIRECT_URI' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'PassEnv MYLOANS_OAUTH2_SCOPE' >> /usr/local/apache2/conf/httpd.conf
COPY backend.cgi /usr/local/apache2/cgi-bin/backend.cgi
COPY --from=build /root/dist/. /usr/local/apache2/htdocs/
