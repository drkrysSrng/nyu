<img align="left" height="60" src="nyu.jpg" alt="Nyu">

# NYU-PROXY

Wireguard Container proxy using 3proxy binary to redirect the traffic.

## Easy way

1. Download this repository:

```commandline
git clone https://github.com/drkrysSrng/nyu.git
```
3. Launch the script to create the container(it removes non-used files too) and saving it to a tar.gz:

```commandline
cd nyu/
./scripts/create_nyu.sh
```

## Manual way

1. Download this repository:

```commandline
git clone https://github.com/drkrysSrng/nyu.git
```


2. Compile the docker image using:

```commandline
cd nyu/
docker build --tag nyu:1.0 .
docker save nyu:1.0 | gzip > nyu_1.0.tar.gz
```

3. Load in the destination server:

```commandline
docker load < nyu_1.0.tar.gz

```

4. Launch the docker-compose directly

```commandline
docker-compose up -d
```

## Proxy Adjustments

* The **PUBLIC_IP** must your public IP or your server's to check you are outside or NOT.

```yml
version: '2.1'
services:
  nyu-vpn1:
    image: nyu:1.0
    container_name: nyu-vpn1
    privileged: true
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: always
    ports:
      - 127.0.0.1:9051:9050
      - 127.0.0.1:8118:8118
    volumes:
      - /lib/modules:/lib/modules
      - ./wgconfs:/config
    networks:
      - lucy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - CONF_FILE=/etc/3proxy.cfg
      - WG_FILE=/config/wg1.conf
      - OUT_IP=PUBLIC_IP
      - "NETWORK=cm91dGUgYWRkIC1uZXQgMTcyLjI2LjAuMC8xNSBndyAxNzIuMjkuMzAuMSBkZXYgZXRoMA=="


```

## Problem resolution

* The step to check if it is working correctly: (change the port to the proxy to check)

```commandline
$ curl -x socks5h://localhost:9011 ipinfo.io
$ docker exec -it nyu-vpn1 curl ipinfo.io
```

* Nyu checks and fixes itself automatically, but it is always possible to restart the proxy container: (change docker container name with the container you want to check)

```commandline
$ docker restart nyu-vpn1
```

* Also the complete system can be restarted destroying all the containers and launching them again:

```commandline
$ docker-compose down
$ docker-compose up -d
```


