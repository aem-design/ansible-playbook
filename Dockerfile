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
    sudo \
    which \
    python-setuptools \
    python-devel \
    python-pip \
    libffi \
    libffi-devel \
    openssh-clients \
    openssl-devel \
    tar \
    grep \
    sed \
    git \
    bzip2 \
    which \
    wget

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
    boto \
    bs4 \
    ansible \
    docker-compose \
    docker \
    python-keyczar \
    jinja2-cli \
    pyaem2

RUN \
    echo "==> Setup Base OS" && \
    yum -y update && \
    yum -y install deltarpm epel-release initscripts && \
    yum -y install yum-utils && \
    yum -y groupinstall development && \
    yum -y install ${YUM_PACKAGES}

RUN \
    echo "==> Install Python 3" && \
    yum -y install centos-release-scl scl-utils && \
    yum -y install rh-python36 && \
    echo "==> Set Python 3 as primary..." && \
    touch /etc/profile.d/python3.sh && chmod +x /etc/profile.d/python3.sh && \
    echo "#!/bin/bash">/etc/profile.d/python3.sh && \
    echo "source /opt/rh/rh-python36/enable">>/etc/profile.d/python3.sh && \
    source /opt/rh/rh-python36/enable && \
    echo "==> Check Python ..." && \
    python --version && \
    echo "==> Upgrade Pip ..." && \
    pip install --upgrade pip

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
    rm -rf curl* && \
    \
    echo "==> Upgrade packages dependant on pycurl..." && \
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
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost ansible_connection=local" >> /etc/ansible/hosts

WORKDIR /ansible/playbooks

ENV ANSIBLE_GATHERING="smart" \
    ANSIBLE_HOST_KEY_CHECKING="false" \
    ANSIBLE_RETRY_FILES_ENABLED="false" \
    ANSIBLE_ROLES_PATH="/ansible/playbooks/roles" \
    ANSIBLE_SSH_PIPELINING="True" \
    PYTHONPATH="/ansible/lib" \
    PATH="/ansible/bin:$PATH" \
    ANSIBLE_LIBRARY="/ansible/library"

VOLUME ["/sys/fs/cgroup", "/var/run/docker.sock"]

CMD ["ansible-playbook"]
