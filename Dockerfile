# Unbound
#
FROM ubuntu:14.04
MAINTAINER  Anusorn Tantara <atantara@comnet.in.th>

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN /usr/sbin/sshd
RUN apt-get -y install build-essential
RUN apt-get -y install curl wget
RUN apt-get -y install tcpdump
RUN apt-get -y install subversion
RUN apt-get -y install byacc flex
RUN apt-get -y install libssl-dev libexpat-dev
RUN curl ftp://ftp.isc.org/isc/bind9/9.10.2/bind-9.10.2.tar.gz|tar -xzv \
        && cd bind-9.10.2 \
        && ./configure --without-openssl --disable-symtable \
        && make \
        && cp ./bin/dig/dig /usr/bin/
RUN rm -rf bind-9.10.2
RUN mkdir unbound-src && cd unbound-src
RUN svn checkout http://unbound.nlnetlabs.nl/svn/branches/edns-subnet/
RUN cd edns-subnet \
    && ./configure --enable-subnet \
    && make \
    && make install
RUN adduser unbound
WORKDIR /usr/local/etc/unbound
RUN cd /usr/local/etc/unbound && mv unbound.conf default_unbound.conf
COPY ./unbound.conf /usr/local/etc/unbound
RUN /usr/local/sbin/unbound

EXPOSE 22

EXPOSE 53
EXPOSE 53/udp

CMD ["/usr/sbin/sshd","-D"]
