## CentOS 7 with Ansible-Playbook

[![pipeline status](https://gitlab.com/aem.design/ansible-playbook/badges/master/pipeline.svg)](https://gitlab.com/aem.design/ansible-playbook/commits/master)

This is docker image based on CentOS 7 with Ansible-Playbook

### Included Packages

Following is the list of packages included

* python                - for ansible
* pyaem                 - for aem automation [pyaem](https://github.com/wildone/pyaem)
* ansible               - for running playbooks
* ansible-playbook      - for running playbooks

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
