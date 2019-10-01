FROM        centos:latest

MAINTAINER  devops <devops@aem.design>

LABEL   os="centos" \
        container.description="dockerise ansible-playbook" \
        version="1.0.0" \
        imagename="ansible-playbook" \
        test.command="ansible-playbook --version | awk 'NR==1 {print $2}'" \
        test.command.verify="2.8.5"


ARG ANSIBLE_VERSION=2.8.5
ARG CURL_VERSION="7.66.0"
ARG CURL_URL="http://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"

ENV YUM_PACKAGES \
    bzip2 \
    grep \
    libcurl-devel \
    libffi \
    libffi-devel \
    libtool-ltdl \
    libxml2-devel \
    libxslt-devel \
    openssh-clients \
    openssl-devel \
    patch \
    rh-python36 \
    rh-python36-python-devel \
    rh-python36-python-pip \
    rh-python36-python-setuptools \
    rh-python36-python-tools \
    rh-python36-python-six \
    sed \
    sudo \
    tar \
    unzip \
    wget \
    which \
    zlib-devel

ENV PIP_PACKAGES \
    setuptools \
    pycrypto \
    BeautifulSoup4 \
    xmltodict \
    paramiko \
    PyYAML \
    Jinja2 \
    httplib2 \
    boto \
    xmltodict \
    six \
    requests \
    python-consul \
    passlib \
    cryptography \
    appdirs \
    packaging \
    boto3 \
    bs4 \
    ansible \
    docker-compose \
    docker \
    python-keyczar \
    jinja2-cli \
    pyaem2

ENV APP_ROOT=/ansible
COPY ./root/ /

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${APP_ROOT}/etc/scl_enable \
    ENV=${APP_ROOT}/etc/scl_enable \
    PROMPT_COMMAND=". ${APP_ROOT}/etc/scl_enable"

# Setup base os packages
RUN \
    echo "==> Setup Base OS" && \
    yum -y update && \
    yum -y install deltarpm epel-release initscripts centos-release-scl scl-utils && \
    yum -y install yum-utils && \
    yum -y groupinstall development && \
    yum -y install ${YUM_PACKAGES}

# Install latest curl
RUN \
    echo "==> Downloading curl..." && \
    wget -O curl.tar.gz ${CURL_URL} && tar -xvzf curl.tar.gz && \
    \
    echo "==> Installing curl..." && \
    cd curl-* && ./configure && make && make install && cd - && \
    \
    echo "==> Remove current curl..." && \
    rm -rf /usr/bin/curl /usr/bin/curl-config && \
    \
    echo "==> Creating links to new curl and curl-config..." && \
    ln -s /usr/local/bin/curl /usr/bin/curl && \
    ln -s /usr/local/bin/curl-config /usr/bin/curl-config && \
    \
    echo "==> Removing old libcurl link..." && \
    rm -rf /usr/lib64/libcurl.so /usr/lib64/libcurl.so.4 && \
    \
    echo "==> Creating new libcurl links..." && \
    cd /usr/lib64 && \
    ln -s /usr/local/lib/libcurl.so libcurl.so && \
    ln -s /usr/local/lib/libcurl.so.4 libcurl.so.4 && \
    cd - && \
    \
    echo "==> Removing curl sources..." && \
    rm -rf curl*

# Install Python3 with Virtenvironment
RUN \
    echo "==> Enable Python 3 and create Virtual Environment" && \
    source scl_source enable rh-python36 && \
    virtualenv ${APP_ROOT} --system-site-packages && \
    source /ansible/bin/activate && \
    echo "==> Check Python ..." && \
    python --version && \
    which python && \
    which pip && \
    echo "==> Upgrade Pip ..." && \
    pip install --upgrade pip && \
    echo "==> Upgrade packages dependant on pycurl..." && \
    which python && \
    which pip && \
    pip install --upgrade --ignore-installed pyudev rtslib-fb && \
    \
    echo "==> Installing pycurl with openssl..." && \
    export PYCURL_SSL_LIBRARY=openssl && \
    pip install --ignore-installed pycurl && \
    \
    echo "==> Pycurl status..." && \
    python -c 'import pycurl; print(pycurl.version)' && \
    \
    echo "==> Installing ansible and modules..." && \
    pip install --upgrade --ignore-installed ${PIP_PACKAGES} && \
    \
    echo "==> Pycurl status..." && \
    python -c 'import pycurl; print(pycurl.version)' && \
    \
    echo "==> Curl status..." && \
    curl -V && \
    \
    echo "==> Pycurl status..." && \
    python -c 'import pycurl; print(pycurl.version)' && \
    \
    echo "==> PyAEM2 status..." && \
    python -c 'import pyaem2; print(pyaem2.__version__)' && \
    \
    echo "==> Disable requiretty..." && \
    sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers && \
    \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost ansible_connection=local" >> /etc/ansible/hosts

RUN \
    echo "==> Add Virtual Environment Activation to profile activation..."  && \
    touch /etc/profile.d/python3.sh && chmod +x /etc/profile.d/python3.sh && \
    echo "#!/bin/bash">/etc/profile.d/python3.sh && \
    echo "source /ansible/bin/activate">>/etc/profile.d/python3.sh && \
    echo "==> Link /usr/bin/python to /ansible/bin/python..."  && \
    ln -fs /ansible/bin/python /usr/bin/python

WORKDIR /ansible/playbooks

ENV ANSIBLE_GATHERING="smart" \
    ANSIBLE_HOST_KEY_CHECKING="false" \
    ANSIBLE_RETRY_FILES_ENABLED="false" \
    ANSIBLE_ROLES_PATH="${APP_ROOT}/playbooks/roles" \
    ANSIBLE_SSH_PIPELINING="True" \
    PYTHONPATH="${APP_ROOT}/lib" \
    PATH="${APP_ROOT}/bin:/opt/rh/rh-python36/root/usr/bin:$PATH" \
    ANSIBLE_LIBRARY="${APP_ROOT}/library"

VOLUME ["/sys/fs/cgroup", "/var/run/docker.sock", "/ansible/playbooks"]

CMD ["ansible-playbook"]
