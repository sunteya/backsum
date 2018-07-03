FROM ubuntu:rolling

RUN rm /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update # 20180703
RUN apt-get -y install ubuntu-core-libs
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

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /data
ADD backsum.sh /bin/backsum
ADD cleanup.sh /bin/cleanup

WORKDIR /data
CMD ["/bin/bash", "-l"]
