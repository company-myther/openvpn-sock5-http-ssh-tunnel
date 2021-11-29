FROM curve25519xsalsa20poly1305/openvpn-socks5:latest

COPY socks5-entrypoint.sh /usr/local/bin
RUN apk add --update nodejs npm && apk add --update npm \
    && npm install -g http-proxy-to-socks && apk add --update openssh && \
    chmod +x /usr/local/bin/socks5-entrypoint.sh
