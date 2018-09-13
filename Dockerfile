FROM centos:7.5.1804 as ipxe-builder
ENV IPXE_MASTER_SNAPSHOT=https://git.ipxe.org/ipxe.git/snapshot/master.tar.gz
RUN yum -y install gcc make perl
RUN mkdir /tmp/ipxe
RUN curl -f ${IPXE_MASTER_SNAPSHOT} -o /tmp/ipxe/master.tar.gz
RUN tar --strip-components=1 -xzf /tmp/ipxe/master.tar.gz -C /tmp/ipxe
WORKDIR /tmp/ipxe/src
RUN make configure
RUN make bin-x86_64-efi/ipxe.efi

FROM centos:7.5.1804
ENV OPENSTACK_RELEASE=rocky
RUN groupadd -g 997 ironic && useradd -u 998 -d /var/lib/ironic -s /sbin/nologin -M -g ironic ironic
RUN rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm && \
    yum -y install centos-release-openstack-${OPENSTACK_RELEASE} && \
    yum -y install epel-release && \
    yum -y upgrade && \
    yum -y install mysql-community-client \
                   openstack-ironic-api \
                   openstack-ironic-conductor \
                   patch \
                   python-ironicclient \
                   python2-openstackclient.noarch \
                   tftp-server \
                   qemu-img \
                   syslinux \
                   wget \
                   xinetd &&\
    mv /etc/ironic/rootwrap.d /etc/rootwrap.d-ironic && \
    mkdir /tmp/patches
COPY --from=ipxe-builder /tmp/ipxe/src/bin-x86_64-efi/ipxe.efi /usr/share/syslinux/ipxe.efi

VOLUME /etc/ironic
USER ironic:ironic
