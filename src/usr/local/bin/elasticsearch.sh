#! /bin/bash
# #################################################################
# NAME: elasticsearch.sh
# DESC: Elasticsearch startup file.
#
# LOG:
# yyyy/mm/dd [user] [version]: [notes]
# 2014/10/23 cgwong v0.1.0: Initial creation
# 2014/11/07 cgwong v0.1.1: Use config file switch.
# 2014/11/10 cgwong v0.2.0: Added environment variables.
# 2015/01/28 cgwong v0.3.0: Updated variables.
# 2015/01/29 cgwong v0.5.0: Enabled previous variables.
# 2015/02/02 cgwong v1.0.0: Removed unneeded variables, simplified directories layout.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_VOL=/esvol
ES_CONF=${ES_CONF:-"/esvol/config/elasticsearch.yml"}
ES_CLUSTER_NAME=${ES_CLUSTER_NAME:-"es_cluster01"}
ES_PORT_9200_TCP_ADDR=${ES_PORT_9200_TCP_ADDR:-"9200"}
ES_MULTICAST_ENABLED=${ES_MULTICAST_ENABLED:-"false"}

# Download the config file if given a URL
if [ ! "$(ls -A ${ES_CFG_URL})" ]; then
  curl -Ls -o ${ES_CONF} ${ES_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "[elasticsearch] Unable to download file ${ES_CFG_URL}."
    exit 1
  fi
fi

# Setup for AWS discovery
if [[ ! -z $AWS_ACCESS_KEY && ! -z $AWS_SECRET_KEY && ! -z $AWS_S3_BUCKET && ! -z $AWS_REGION ]]; then
  sed -ie "s/#cloud.aws.access_key: AWS_ACCESS_KEY/cloud.aws.access_key: ${AWS_ACCESS_KEY}/g" $ES_CONF
  sed -ie "s/#cloud.aws.secret_key: AWS_SECRET_KEY/cloud.aws.secret_key: ${AWS_SECRET_KEY}/g" $ES_CONF
  sed -ie "s/#cloud.node.auto_attributes: true/cloud.node.auto_attributes: true/g" $ES_CONF
  sed -ie "s/#repositories.s3.bucket: AWS_S3_BUCKET/repositories.s3.bucket: ${AWS_S3_BUCKET}/g" $ES_CONF
fi

sed -ie "s/#discovery.zen.ping.multicast.enabled: ES_MULTICAST_ENABLED/discovery.zen.ping.multicast.enabled: ${ES_MULTICAST_ENABLED}/g" $ES_CONF

if [[ ! -z "$ES_NODE_NAME" ]]; then
  sed -ie "s/#node.name: ES_NODE_NAME/node.name: ${ES_NODE_NAME}/g" $ES_CONF
fi

if [[ ! -z "$ES_RECOVER_AFTER_NODES" ]]; then
  sed -ie "s/#gateway.recover_after_nodes: ES_RECOVER_AFTER_NODES/gateway.recover_after_nodes: ${ES_RECOVER_AFTER_NODES}/g" $ES_CONF
fi

if [[ ! -z "$ES_MINIMUM_MASTER_NODES" ]]; then
  sed -ie "s/#discovery.zen.minimum_master_nodes: ES_MINIMUM_MASTER_NODES/discovery.zen.minimum_master_nodes: ${ES_MINIMUM_MASTER_NODES}/g" $ES_CONF
fi

if [[ ! -z "$ES_UNICAST_HOSTS" ]]; then
  sed -ie "s/#discovery.zen.ping.unicast.hosts: ES_UNICAST_HOSTS/discovery.zen.ping.unicast.hosts: ${ES_UNICAST_HOSTS}/g" $ES_CONF
fi

if [[ ! -z "$ES_NETWORK_PUBLISH_HOST" ]]; then
  sed -ie "s/#network.publish_host: ES_NETWORK_PUBLISH_HOST/network.publish_host: ${ES_NETWORK_PUBLISH_HOST}/g" $ES_CONF
fi

if [[ ! -z "$ES_NETWORK_BIND_HOST" ]]; then
  sed -ie "s/#network.bind_host: ES_NETWORK_BIND_HOST/network.bind_host: ${ES_NETWORK_BIND_HOST}/g" $ES_CONF
fi

if [[ ! -z "$ES_NETWORK_HOST" ]]; then
  sed -ie "s/#network.host: ES_NETWORK_HOST/network.host: ${ES_NETWORK_HOST}/g" $ES_CONF
fi

if [[ ! -z "$ES_NODE_DATA" ]]; then
  sed -ie "s/#node.data: ES_NODE_DATA/node.data: ${ES_NODE_DATA}/g" $ES_CONF
fi

if [[ ! -z "$ES_NODE_MASTER" ]]; then
  sed -ie "s/#node.master: ES_NODE_MASTER/node.master: ${ES_NODE_MASTER}/g" $ES_CONF
fi


# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  /opt/elasticsearch/bin/elasticsearch \
    --config=${ES_CONF} \
    --cluster.name=${ES_CLUSTER_NAME} \
    "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
