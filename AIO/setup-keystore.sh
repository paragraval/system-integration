#!/bin/bash
# ===============LICENSE_START=======================================================
# Acumos Apache-2.0
# ===================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights reserved.
# ===================================================================================
# This Acumos software file is distributed by AT&T
# under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# This file is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===============LICENSE_END=========================================================
#
#. What this is: script to setup host-mapped PVs under kubernetes or docker
#.
#. Prerequisites:
#. - acumos-env.sh script prepared through oneclick_deploy.sh or manually, to
#.   set install options (e.g. docker/k8s)
#. - host folder /var/$ACUMOS_NAMESPACE/certs created through setup-pv.sh
#.
#. Usage: intended to be called directly from oneclick_deploy.sh
#.

function setup() {
  trap 'fail' ERR
  if [[ ! -e /var/$ACUMOS_NAMESPACE/certs ]]; then
    log "Create /var/$ACUMOS_NAMESPACE/certs as cert storage folder"
    sudo mkdir -p /var/$ACUMOS_NAMESPACE/certs
    # Have to set user and group to allow pod access to PVs
    sudo chown $USER:$USER /var/$ACUMOS_NAMESPACE
    sudo chown $USER:$USER /var/$ACUMOS_NAMESPACE/certs
  fi

  if [[ ! -e /var/$ACUMOS_NAMESPACE/certs/$ACUMOS_CERT ]]; then
    if [[ -e certs/$ACUMOS_CERT ]]; then
      log "Using existing user-prepared files in certs subfolder"
    else
      log "Creating new certs in certs subfolder"
      cd certs
      bash setup-certs.sh $ACUMOS_CERT_PREFIX $ACUMOS_DOMAIN
      bash update-cert-env.sh
      cd ..
    fi
    log "Copying certs to /var/$ACUMOS_NAMESPACE/certs/"
    cp $(ls certs/* | grep -v '\.sh') /var/$ACUMOS_NAMESPACE/certs/.
  else
    log "Using existing certs in /var/$ACUMOS_NAMESPACE/certs/"
  fi
}

source $AIO_ROOT/acumos-env.sh
source $AIO_ROOT/utils.sh
setup