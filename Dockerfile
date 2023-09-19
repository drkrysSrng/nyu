FROM debian:latest

RUN echo "**** Installing dependencies ****" && \
    apt-get update && apt-get -y install \
	git \
	build-essential \ 
	libsasl2-dev \ 
	libldap2-dev \ 
	libssl-dev \
	libgl1-mesa-dev \
    libc6-dev \
	xorg-dev \
    libx11-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    libglu1-mesa-dev \
    pkg-config \
    libxxf86vm-dev \
	wireguard \
	wireguard-tools \
	openresolv \
	procps \
	iproute2 \
	iptables \
    iputils-ping \
    net-tools \
    curl \
    gcc \
    git \
    make \
    ca-certificates 


RUN git clone  https://github.com/3proxy/3proxy.git /tmp/3proxy

WORKDIR /tmp/3proxy

RUN echo "**** Compiling 3proxy...... ****" &&\
    echo "">> Makefile.Linux &&\
    echo PLUGINS = StringsPlugin TrafficPlugin PCREPlugin TransparentPlugin SSLPlugin>>Makefile.Linux &&\
    echo LIBS = -l:libcrypto.a -l:libssl.a -ldl >>Makefile.Linux &&\
    make -f Makefile.Linux &&\
    strip bin/3proxy &&\
    strip bin/StringsPlugin.ld.so &&\
    strip bin/TrafficPlugin.ld.so &&\
    strip bin/PCREPlugin.ld.so &&\
    strip bin/TransparentPlugin.ld.so &&\
    strip bin/SSLPlugin.ld.so &&\
    mkdir /usr/local/lib/3proxy &&\
    mkdir -p /usr/local/3proxy/libexec/ &&\
    cp "/lib/`gcc -dumpmachine`"/libdl.so.* /usr/local/lib/3proxy/ &&\
    cp /usr/local/lib/3proxy/libdl.so.* /lib/  &&\
    cp /tmp/3proxy/bin/3proxy /usr/local/bin/ &&\
    cp /tmp/3proxy/bin/*.ld.so /usr/local/3proxy/libexec/ &&\
    echo "**** Compiled ****"


WORKDIR /app

RUN echo "**** Adding permissions ****" &&\
    groupadd -g 666 3proxy && \
    useradd -u 666 -g 666 3proxy && \
    mkdir -m 777 -p /var/log/3proxy && \
    chown 3proxy:3proxy /var/log/3proxy && \
    mkdir /usr/local/3proxy/conf &&\
    chown -R 65535:65535 /usr/local/3proxy &&\
    chmod -R 550  /usr/local/3proxy &&\
    chmod -R 555 /usr/local/3proxy/libexec &&\
    chown -R root /usr/local/3proxy/libexec 




RUN echo "**** clean up ****" && \
    rm -rf /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

ADD ./scripts/lucy.sh /usr/local/bin/lucy.sh
ADD ./config/3proxy.cfg /etc/3proxy.cfg

EXPOSE 8118 9050

CMD ["/usr/local/bin/lucy.sh"]   


