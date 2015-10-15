FROM alpine:3.2
MAINTAINER Boberg <blazed@darkstar.se>

ENV CONFD_VERSION 0.10.0

RUN \
  apk add --update bash nginx curl && rm -rf /var/cache/apk/*

ADD build/nginx.toml /etc/confd/conf.d/nginx.toml
ADD build/nginx.conf.tmpl /etc/confd/templates/nginx.conf.tmpl

WORKDIR /usr/local/bin/
RUN \
  curl -sSL https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 -o confd &&\
  chmod +x confd

RUN mkdir -p /opt/no-site
ADD site/404.html /opt/no-site/404.html
ADD site/default.conf /etc/nginx/conf.d/default.conf

ADD build/run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

EXPOSE 80

CMD ["/opt/run.sh"]