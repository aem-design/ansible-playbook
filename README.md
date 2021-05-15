## CentOS 8 with Ansible-Playbook

[![build](https://github.com/aem-design/docker-ansible-playbook/actions/workflows/build.yml/badge.svg?branch=centos8)](https://github.com/aem-design/docker-ansible-playbook/actions/workflows/build.yml) 
[![github license](https://img.shields.io/github/license/aem-design/ansible-playbook)](https://github.com/aem-design/ansible-playbook) 
[![github issues](https://img.shields.io/github/issues/aem-design/ansible-playbook)](https://github.com/aem-design/ansible-playbook) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/ansible-playbook)](https://github.com/aem-design/ansible-playbook) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/ansible-playbook)](https://github.com/aem-design/ansible-playbook) 
[![docker stars](https://img.shields.io/docker/stars/aemdesign/ansible-playbook)](https://hub.docker.com/r/aemdesign/ansible-playbook) 
[![docker pulls](https://img.shields.io/docker/pulls/aemdesign/ansible-playbook)](https://hub.docker.com/r/aemdesign/ansible-playbook) 
[![github release](https://img.shields.io/github/release/aem-design/ansible-playbook)](https://github.com/aem-design/ansible-playbook)

This is docker image based on CentOS 8 with Ansible-Playbook

### Included Packages

Following is the list of packages included

| Package | Version | Notes  |
| ---  | ---    | --- |
| python | 3.6+ | for ansible |
| pyaem2 | | for aem automation [pyaem](https://github.com/aem-design/pyaem2) |
| ansible | | for running playbooks |
| ansible-playbook | | for running playbooks |
| docker-cli | | for running docker commands |

### Usage

Test out playbooks in current directory

```bash
docker run  -it --entrypoint="" -v $(pwd):/ansible/playbooks  aemdesign/ansible-playbook bash
```

Advanced usage for configuring AEM instances on Docker Host using Ansible Playbook

```bash

LOCAL_IP="$(ipconfig | grep "(Default Switch)" -A 6 | grep "IPv4 Address" | head -n1 | awk -F ": " '/1/ {print $2}')"
LOCAL_DOCKER_PORT=2376
ANSIBLE_PLAYBOOK="docker-localdev.yml"
ANSIBLE_INVENTORY="inventory/localdev-docker"
ANSIBLE_INCLUDE_TAGS="docker-container,aem-packages,aem-verify,aem-install-package-using-ansible,aem-license"

DOCKER_CONTAINER="aemdesign/ansible-playbook"

AUTHOR_ADDRESS="author01.aem.design"
PUBLISH_ADDRESS="publish01.aem.design"
PUBLISH_DISPATCHER_ADDRESS="dispatcher02.aem.design"
SELENIUMGRID_ADDRESS="seleniumgrid.aem.design"
SELENIUMGRIDCHROME1_ADDRESS="seleniumgridnodechrome1.aem.design"
SELENIUM_PORT=32768


AUTHOR_HOST=${LOCAL_IP}
PUBLISH_HOST=${LOCAL_IP}
DISPATCHER_HOST=${LOCAL_IP}
SELENIUM_HOST=${LOCAL_IP}
DOCKER_HOST=${LOCAL_IP}
DOCKER_PORT=${LOCAL_DOCKER_PORT}

docker run -it --rm -v $(pwd):/ansible/playbooks --entrypoint="" --add-host $AUTHOR_ADDRESS:$AUTHOR_HOST --add-host $PUBLISH_ADDRESS:$PUBLISH_HOST --add-host $PUBLISH_DISPATCHER_ADDRESS:$DISPATCHER_HOST --add-host $SELENIUMGRID_ADDRESS:$DOCKER_HOST --add-host $SELENIUMGRIDCHROME1_ADDRESS:$SELENIUM_HOST $DOCKER_CONTAINER bash -c "export ANSIBLE_LIBRARY=./library && ansible-playbook $ANSIBLE_PLAYBOOK -i $ANSIBLE_INVENTORY --extra-vars "service_aem_host=$LOCAL_IP" --tags=$ANSIBLE_INCLUDE_TAGS -e docker_host=tcp://$DOCKER_HOST:$DOCKER_PORT"
```
