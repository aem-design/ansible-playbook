FROM        centos:latest

MAINTAINER  devops <devops@aem.design>

LABEL   os.version="centos" \
        container.description="dockerise ansible-playbook"

ARG ANSIBLE_VERSION=2.5.3
ARG CURL_VERSION="7.54.1"
ARG CURL_URL="http://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"
ARG PYAEM_URL="https://github.com/wildone/pyaem/archive/master.zip"

ENV YUM_PACKAGES \
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
    'docker-compose<1.20.0' \
    'docker<3.0' \
    python-keyczar

RUN \
    yum -y install epel-release && \
    yum -y install ${YUM_PACKAGES} && \
    pip install --upgrade pip && \
    yum -y groupinstall development && \
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
    echo "==> Installing pyaem..." && \
    pip install --no-deps ${PYAEM_URL} && \
    \
    echo "==> Curl status..." && \
    curl -V && \
    \
    echo "==> Pycurl status..." && \
    python -c 'import pycurl; print(pycurl.version)' && \
    \
    echo "==> PyAEM status..." && \
    python -c 'import pyaem; print(pyaem.__version__)' && \
    \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

WORKDIR /ansible/playbooks

ENV ANSIBLE_GATHERING="smart" \
    ANSIBLE_HOST_KEY_CHECKING="false" \
    ANSIBLE_RETRY_FILES_ENABLED="false" \
    ANSIBLE_ROLES_PATH="/ansible/playbooks/roles" \
    ANSIBLE_SSH_PIPELINING="True" \
    PYTHONPATH="/ansible/lib" \
    PATH="/ansible/bin:$PATH" \
    ANSIBLE_LIBRARY="/ansible/library"

ENTRYPOINT ["ansible-playbook"]