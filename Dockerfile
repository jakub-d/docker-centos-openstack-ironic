FROM centos:7 as ipxe-builder
ENV IPXE_MASTER_SNAPSHOT=https://git.ipxe.org/ipxe.git/snapshot/master.tar.gz
RUN yum -y install gcc xz-devel make perl
RUN mkdir /tmp/ipxe
RUN curl -f ${IPXE_MASTER_SNAPSHOT} -o /tmp/ipxe/master.tar.gz
RUN tar --strip-components=1 -xzf /tmp/ipxe/master.tar.gz -C /tmp/ipxe
WORKDIR /tmp/ipxe/src
COPY ipxescript /tmp/ipxe/src/
RUN make configure
RUN make bin/undionly.kpxe bin-x86_64-efi/ipxe.efi EMBED=/tmp/ipxe/src/ipxescript

FROM centos:7
ENV OPENSTACK_RELEASE=train
RUN groupadd -g 997 ironic && useradd -u 998 -d /var/lib/ironic -s /sbin/nologin -M -g ironic ironic
RUN yum -y install centos-release-openstack-${OPENSTACK_RELEASE} && \
    yum -y install epel-release && \
    yum -y upgrade && \
    yum -y install git \
                   ipxe-bootimgs \
                   mariadb \
                   openstack-ironic-api \
                   openstack-ironic-conductor \
                   patch \
                   python-ironicclient \
                   python2-openstackclient.noarch \
                   python2-PyMySQL \
                   rsyslog \
                   qemu-img \
                   syslinux \
                   tftp-server \
                   wget &&\
    mv /etc/ironic/rootwrap.d /etc/rootwrap.d-ironic && \
    mkdir /tmp/patches
COPY --from=ipxe-builder /tmp/ipxe/src/bin-x86_64-efi/ipxe.efi /usr/share/syslinux/custom-ipxe.efi
COPY --from=ipxe-builder /tmp/ipxe/src/bin/undionly.kpxe /usr/share/syslinux/custom-undionly.kpxe
COPY rsyslog.conf /etc/

VOLUME /etc/ironic
USER ironic:ironic
