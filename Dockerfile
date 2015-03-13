FROM centos:7
MAINTAINER Alfred Shen <alfredcs@yahoo.com>
ENV container docker
# -----------------------------------------------------------------------------
# Additioanl rpm installation
# -----------------------------------------------------------------------------
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
	(cd /lib/systemd/system/sysinit.target.wants/; \
	for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); 
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;\
	rm -f /etc/systemd/system/*.wants/*;\
	rm -f /lib/systemd/system/local-fs.target.wants/*; \
	rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
	rm -f /lib/systemd/system/basic.target.wants/*;\
	rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum -y install \
	vim \
	sudo \
	passwd \
	shadow-utils \
	net-tools \
	openssh-server \
	openssh-clients \
	python-pip \
	&& yum -y update bash \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all
# -----------------------------------------------------------------------------
# Generate ssh host keys for sshd
# -----------------------------------------------------------------------------
RUN sed -i 's/^# %wheel\tALL=(ALL)\tALL/%wheel\tALL=(ALL)\tALL/g' /etc/sudoers

RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
	ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
	sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
	sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
	sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
	sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Post installation/configuration updates
# -----------------------------------------------------------------------------
VOLUME [ "/sys/fs/cgroup" ]
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
ENV AUTHORIZED_KEYS **None**
EXPOSE 22
CMD ["/run.sh"]
#CMD ["/usr/sbin/init"]
