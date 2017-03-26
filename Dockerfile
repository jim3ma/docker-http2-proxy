FROM alpine:3.5

LABEL maintainer Jim Ma <majinjing3@gmail.com>

ENV SQUID_VERSION=3.5.23-r0 \
    SQUID_CACHE_DIR=/var/spool/squid3 \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=squid

ENV NGHTTP2_VERSION=1.20.0

RUN apk --no-cache add wget ca-certificates squid=${SQUID_VERSION} \
    && mv /etc/squid/squid.conf /etc/squid/squid.conf.dist \
    && wget https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && tar -zxvf nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && rm -f nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && cd nghttp2-${NGHTTP2_VERSION} \
    && apk --no-cache add python http-parser bash openssl libxml2 libev libevent jemalloc jansson c-ares libatomic libgomp binutils libffi expat libbz2 libssl1.0 \
    && apk --no-cache add g++ autoconf automake make libtool openssl-dev libxml2-dev libev-dev libevent-dev zlib-dev jemalloc-dev jansson-dev c-ares-dev \
    && ./configure --disable-python-bindings \
    && make && make install-strip \
    && mkdir -p /var/log/nghttpx/ \
    && apk del g++ autoconf automake make libtool openssl-dev libxml2-dev libev-dev libevent-dev zlib-dev jemalloc-dev jansson-dev c-ares-dev \
    && cd .. && rm -rf nghttp2-${NGHTTP2_VERSION}

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

COPY nghttpx.conf /etc/nghttpx/nghttpx.conf

# HTTP Proxy
EXPOSE 3128/tcp
# HTTPS Proxy
EXPOSE 443/tcp

VOLUME ["${SQUID_CACHE_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
