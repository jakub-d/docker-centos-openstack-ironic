FROM centos:7.5.1804
ENV OPENSTACK_RELEASE=rocky
RUN groupadd -g 997 ironic && useradd -u 998 -d /var/lib/ironic -s /sbin/nologin -M -g ironic ironic
RUN rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm && \
    yum -y install centos-release-openstack-${OPENSTACK_RELEASE} && \
    yum -y install epel-release && \
    yum -y upgrade && \
    yum -y install ipxe-bootimgs \
                   mysql-community-client \
                   openstack-ironic-api \
                   openstack-ironic-conductor \
                   patch \
                   python-ironicclient \
                   python2-openstackclient.noarch \
                   tftp-server \
                   qemu-img \
                   syslinux \
                   wget && \
    mv /etc/ironic/rootwrap.d /etc/rootwrap.d-ironic && \
    mkdir /tmp/patches

VOLUME /etc/ironic
USER ironic:ironic
