## openvpn to socks5, http proxy, ssh tunnel

## use:
```yaml
version: "3"
services:
  openvpn:
    image: mythcoder/openvpn-sock5-http-ssh-tunnel
    devices:
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    volumes:
      # openvpn config dir
      - "./vpn-config:/vpn/"
    environment:
      # vpn config file
      - OPENVPN_CONFIG=/vpn/server.ovpn
      - SOCKS5_PORT=1080
      - SOCKS5_USER=
      - SOCKS5_PASS=
      - ROOT_PASSWORD=123456
      - HTTP_PROXY_PORT=3080
      - SSH_PORT=1022
    ports:
      - "2080:1080"
      - "3080:3080"
      - "1022:1022"
```

[source - Github](https://github.com/imythu/openvpn-sock5-http-ssh-tunnel/tree/master)
