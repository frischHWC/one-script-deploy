export PAYWALL_USER=
export PAYWALL_PASSWORD=
export LICENSE_FILE="/root/license.txt"
export NODE_KEY="/root/frisch.pem"

export REALM=FRISCH.CLOUDERA.COM
export CLUSTER_NAME="bootcamp"



./setup-cluster.sh \
    --cluster-name=${CLUSTER_NAME} \
    --realm=${REALM} \
    \
    --license-file=${LICENSE_FILE} \
    \
    --paywall-username=${PAYWALL_USER} \
    --paywall-password=${PAYWALL_PASSWORD} \
    \
    --node-user="root" \
    --node-key=${NODE_KEY} \
    \
    --cluster-type="pvc" \
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
    --os="rhel" \
    --os-version="8.6" \
    \
    --node-ipa="fri-ipa.cloudera.local" \
    --nodes-base="fri-base-1.cloudera.local fri-base-2.cloudera.local fri-base-3.cloudera.local fri-base-4.cloudera.local fri-base-5.cloudera.local fri-base-6.cloudera.local" \
    --nodes-ecs="fri-ecs-1.cloudera.local fri-ecs-2.cloudera.local fri-ecs-3.cloudera.local"