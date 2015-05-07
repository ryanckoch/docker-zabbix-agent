FROM ryanckoch/docker-ubuntu-14.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install locales && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get -y install ucf procps iproute supervisor

COPY etc/supervisor/ /etc/supervisor/
COPY files/zabbix-agent_2.2.7+dfsg-1.1_amd64.deb /root/
COPY etc/zabbix/ /etc/zabbix/
COPY etc/sudoers.d/zabbix etc/sudoers.d/zabbix
COPY etc/zabbix/crontab /var/spool/cron/crontabs/zabbix
COPY run.sh /

RUN apt-get -y install --no-install-recommends pciutils libcurl3-gnutls \
    libldap-2.4-2 cron curl jq netcat-openbsd sudo vim && \
    rm -rf /var/lib/apt/lists/*

RUN dpkg -i /root/zabbix-agent_2.2.7+dfsg-1.1_amd64.deb

RUN mkdir -p /var/lib/zabbix && \
    chmod 700 /var/lib/zabbix && \
    chown zabbix:zabbix /var/lib/zabbix && \
    usermod -d /var/lib/zabbix zabbix && \
    usermod -a -G adm zabbix && \
    chmod 400 /etc/sudoers.d/zabbix && \
    chmod 600 /var/spool/cron/crontabs/zabbix && \
    chown zabbix:crontab /var/spool/cron/crontabs/zabbix && \
    chmod +x /run.sh

EXPOSE 10050
ENTRYPOINT ["/run.sh"]
CMD [""]
