#!/usr/bin/env bash
nohup hpts -s 127.0.0.1:${SOCKS5_PORT:=1080} -p ${HTTP_PROXY_PORT:=3080}  >/dev/null 2>&1 &
nohup nginx > /dev/null 2>&1 &
mkdir -p ~/.ssh
adduser ssh-tunnel
echo "root:${ROOT_PASSWORD:=123456}" | chpasswd
ssh-keygen -q -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key <<<y >/dev/null 2>&1
sed -i 's/#Port 22/Port '"${SSH_PORT:=1022}"'/' /etc/ssh/sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config
nohup /usr/sbin/sshd -D > /dev/null 2>&1 &

function spawn {
    if [[ -z ${PIDS+x} ]]; then PIDS=(); fi
    "$@" &
    PIDS+=($!)
}

function join {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            wait "${pid}"
        done
    fi
}

function on_kill {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            kill "${pid}" 2> /dev/null
        done
    fi
    kill "${ENTRYPOINT_PID}" 2> /dev/null
}

export ENTRYPOINT_PID="${BASHPID}"

trap "on_kill" EXIT
trap "on_kill" SIGINT

spawn socks5

if [[ -n "${SOCKS5_UP}" ]]; then
    spawn "${SOCKS5_UP}" "$@"
elif [[ $# -gt 0 ]]; then
    "$@"
fi

if [[ $# -eq 0 || "${DAEMON_MODE}" == true ]]; then
    join
fi

