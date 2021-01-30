FROM ubuntu:rolling

RUN rm /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update # 2021-01-29
# RUN apt-get -y install ubuntu-core-libs
RUN apt-get -y install vim
RUN apt-get -y install rsync
RUN apt-get -y install mtr
RUN apt-get -y install bash-completion
RUN apt-get -y install ssh
RUN apt-get -y install iftop
RUN apt-get -y install htop
RUN apt-get -y install man
RUN apt-get -y install iputils-ping
RUN apt-get -y install net-tools
RUN apt-get -y install zsh
RUN apt-get -y install fish

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD backsum.sh /bin/backsum

RUN mkdir -p /data
WORKDIR /data

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash", "-l" ]
