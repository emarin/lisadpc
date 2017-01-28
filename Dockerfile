FROM centos:latest
MAINTAINER eLISA DPC ccavet@apc.in2p3.fr

RUN yum -y update
RUN yum install -y epel-release
RUN yum install -y git
RUN yum install -y make
RUN yum install -y wget nano
RUN yum install -y gcc-c++

RUN wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.tar.gz && tar zxvf cmake-3.7.2-Linux-x86_64.tar.gz && mv cmake-3.7.2-Linux-x86_64 /usr/lib/cmake
RUN rm cmake-3.7.2-Linux-x86_64.tar.gz
RUN yum install -y fftw3-devel
RUN yum install -y gsl-devel
RUN yum install -y python-ipython numpy
RUN yum install -y rpm-build
RUN yum install -y boost boost-devel boost-doc
RUN yum install -y lcov
RUN yum install -y eigen3-devel glog-devel gflags-devel bc
RUN yum install -y libtool
RUN yum install -y pygtk2-devel pcre-devel
RUN yum install -y hdf5 hdf5-devel

RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install --upgrade pip
RUN pip install gcovr
RUN pip install mkdocs
RUN pip install h5py scipy

ENV CXX c++

# install libcmaes
RUN git clone https://github.com/beniz/libcmaes.git
RUN cd libcmaes && ./autogen.sh && ./configure --prefix=/usr/local/libcmaes && make && make install

# install swig
RUN wget https://sourceforge.net/projects/swig/files/swig/swig-3.0.8/swig-3.0.8.tar.gz && tar xvzf swig-3.0.8.tar.gz
RUN cd swig-3.0.8 && ./configure && make && make install
RUN rm -rf swig-3.0.8.tar.gz

## PyCBC
RUN git clone https://github.com/ligo-cbc/pycbc.git
RUN cd pycbc && python setup.py install

RUN yum install -y doxygen
WORKDIR /workspace
RUN cd /workspace
# Install Essentials
RUN yum update -y && \
         yum clean all

# Install Packages
RUN yum install -y git && yum install -y wget && yum install -y openssh-server && yum install -y java-1.8.0-openjdk && yum install -y sudo && yum clean all

# set java home
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk*

# gen dummy keys, centos doesn't autogen them like ubuntu does
RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User
RUN useradd jenkins -m -s /bin/bash

# Add public key for Jenkins login
RUN mkdir /home/jenkins/.ssh

RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6VDSqF6WHFV/XPwdCNfFvpbOQJvN4e6n+Xqa92qoY1cI5DqmoyNAj/C/P62HErdK30wauSCKJbhUdSvtFDC61a8M32cjSxHj8Pjc4ZxSyShlmQMpRQJKj9NEjLUMeHJKS+vF4lCnB6b5wgbNMOPJEUd2jTo9LEd45LPGLjbNAnKJEHp/oq+7RfonwacNh6tHSgWguAvt2a1IlPGLSmiiBIn3RHrpfbkCOt809QHuTCF/VJRnuKett/oQIvlWQTlf+4rMxUGAbuzpz//K2jM+2hD4U73ePszO9rCLlpQuMEUekCpoTtPKn9V9RqcYE7ynhQRZfGQXjYVekdmEv15Dl access key for Jenkins slaves" >> /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins /home/jenkins
RUN chgrp -R jenkins /home/jenkins
RUN chmod 600 /home/jenkins/.ssh/authorized_keys
RUN chmod 700 /home/jenkins/.ssh

# Add the jenkins user to sudoers
RUN echo "jenkins  ALL=(ALL)  ALL" >> /etc/sudoers

RUN yum install -y cppcheck

# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]