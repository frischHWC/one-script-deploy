export PAYWALL_USER=
export PAYWALL_PASSWORD=
export LICENSE_FILE="/home/rocky/license.txt"
export KUBECONFIG_PATH="/home/rocky/kubeconfig"
export OC_TAR_FILE_PATH="/home/rocky/oc.tar"

export ANSIBLE_REPO_BRANCH="rockylinux"

export REALM=CLOUDERA.ROCKY.COM
export CLUSTER_NAME="rocky"


./setup-cluster.sh \
    --cluster-name=${CLUSTER_NAME} \
    --realm=${REALM} \
    --license-file=${LICENSE_FILE} \
    --paywall-username=${PAYWALL_USER} \
    --paywall-password=${PAYWALL_PASSWORD} \
    --kubeconfig-path=${KUBECONFIG_PATH} \
    --oc-tar-file-path=${OC_TAR_FILE_PATH} \
    \
    --cluster-type="all-services-pvc-no-stream" \
    \
    --pre-install=true \
    --prepare-ansible-deployment=true \
    --install=true \
    --post-install=true \
    --user-creation=true \
    --install-pvc=true \
    --configure-pvc=true \
    --create-cdw=true \
    --create-cml=true \
    --create-cde=true \
    --create-viz=true \
    --data-load=true \
    --free-ipa=true \
    --debug=true \
    \
    --node-ipa="rockyipa.base.local" \
    --nodes-base="rocky1.base.local rocky2.base.local rocky3.base.local rocky4.base.local rocky5.base.local rocky6.base.local rocky7.base.local" \
    --nodes-kts="rocky8.base.local" \
    \
    --install-repo-url="https://github.com/frischHWC/cldr-playbook/archive/refs/heads/${ANSIBLE_REPO_BRANCH}.zip" \
    --ansible-repo-dir=cldr-playbook-$ANSIBLE_REPO_BRANCH
