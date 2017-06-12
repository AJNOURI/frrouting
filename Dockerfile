# FRROUTING image
# AJ NOURI: ajn.bin@gmail.com
# cciethebeginning.wordpress.com
#
FROM phusion/baseimage

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y git wget autoconf libtool libjson-c-dev tar build-essential libxml2 libxml-libxml-perl dialog libglib2.0-dev libc-ares-dev bison flex libtinfo-dev telnet nano python-pip tcpdump automake make gawk libreadline-dev pkg-config python3-dev

WORKDIR /tmp

RUN wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.3.tar.xz
RUN tar -xvf texinfo-6.3.tar.xz
WORKDIR /tmp/texinfo-6.3
RUN ./configure
RUN make
RUN make install

RUN pip install pytest

WORKDIR /tmp
RUN wget http://hpnouri.free.fr/misc/readline-7.0.tar.gz
RUN tar -zxvf readline-7.0.tar.gz
 
WORKDIR /tmp/readline-7.0
RUN ./configure
RUN make
RUN make install


RUN addgroup --system --gid 92 frr
RUN addgroup --system --gid 85 frrvty
RUN adduser --system --ingroup frr --home /var/run/frr/ \
   --gecos "FRR suite" --shell /bin/false frr
RUN usermod -a -G frrvty frr




WORKDIR /
RUN git clone https://github.com/FRRouting/frr
WORKDIR /frr
RUN ./bootstrap.sh
RUN ./configure \
    --enable-exampledir=/usr/share/doc/frr/examples/ \
    --localstatedir=/var/run/frr \
    --sbindir=/usr/lib/frr \
    --sysconfdir=/etc/frr \
    --enable-vtysh \
    --enable-isisd \
    --enable-pimd \
    --enable-watchfrr \
    --enable-ospfclient=yes \
    --enable-ospfapi=yes \
    --enable-multipath=64 \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --enable-configfile-mask=0640 \
    --enable-logfile-mask=0640 \
    --enable-rtadv \
    --enable-tcp-zebra \
    --enable-fpm \
    --enable-ldpd \
    --with-pkg-git-version

RUN ./configure
RUN make
RUN make check
RUN make install


RUN chown -R frr:frr /usr/local/etc
RUN chown -R frr:frr /var/run

RUN install -m 755 -o frr -g frr -d /var/log/frr
RUN install -m 775 -o frr -g frrvty -d /etc/frr
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/zebra.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/bgpd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/ospfd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/ospf6d.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/isisd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/ripd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/ripngd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/pimd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/ldpd.conf
RUN install -m 640 -o frr -g frr /dev/null /etc/frr/nhrpd.conf
RUN install -m 640 -o frr -g frrvty /dev/null /etc/frr/vtysh.conf

RUN LD_LIBRARY_PATH=/usr/local/lib
RUN export LD_LIBRARY_PATH

RUN mkdir /var/opt/frr
RUN chown frr /var/opt/frr


RUN echo include /usr/local/lib >> /etc/ld.so.conf
RUN ldconfig

RUN sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf


VOLUME ["/etc/"]

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#USER frr
WORKDIR /
