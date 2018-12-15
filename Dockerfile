FROM alpine:latest AS build

ENV SNIPROXY_VERSION 0.6.0

RUN apk add --no-cache \
      git autoconf automake build-base \
      bsd-compat-headers gettext-dev libtool \
      libev-dev pcre-dev udns-dev \
 && git clone https://github.com/dlundquist/sniproxy.git /sniproxy \
 && cd /sniproxy \
 && git checkout "$SNIPROXY_VERSION" \
 && ./autogen.sh \
 && ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --mandir=/usr/share/man \
      --infodir=/usr/share/info \
 && make

FROM alpine:latest

COPY --from=build /sniproxy/src/sniproxy /usr/sbin/sniproxy
COPY sniproxy.conf /etc/sniproxy.conf

RUN apk add --no-cache libev pcre udns

EXPOSE 443

CMD [ "sniproxy", "-f", "-c", "/etc/sniproxy.conf" ]
