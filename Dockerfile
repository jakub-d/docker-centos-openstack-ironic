FROM centos:7.5.1804

ENV OPENSTACK_RELEASE=queens

RUN groupadd -g 997 ironic && useradd -u 998 -d /var/lib/ironic -s /sbin/nologin -M -g ironic ironic
RUN rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm && \
    yum -y install centos-release-openstack-${OPENSTACK_RELEASE} && \
    yum -y upgrade && \
    yum -y install mysql-community-client \
                   openstack-ironic-api \
                   openstack-ironic-conductor \
                   patch \
                   python-ironicclient \
                   python-pip \
                   qemu-img \
                   syslinux \
                   wget &&\
    pip --no-cache-dir install ptftpd && \
    mv /etc/ironic/rootwrap.d /etc/rootwrap.d-ironic && \
    mkdir /tmp/patches

VOLUME /etc/ironic
USER ironic:ironic
