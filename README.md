## ElasticSearch Dockerfile

This is a highly configurable [ElasticSearch](https://www.elastic.co/products/elasticsearch) (v1.5.0) [Docker image](https://www.docker.com) built using [Docker's automated build](https://registry.hub.docker.com/u/identakid/elasticsearch/) process published to the public [Docker Hub Registry](https://registry.hub.docker.com/). It has optional AWS EC2 discovery.

It is usually the back-end for a [Logstash](https://www.elastic.co/products/logstash) instance with [Kibana](https://www.elastic.co/products/kibana) as the frontend forming what is commonly referred to as an **ELK stack**.


### How to use this image
To start a basic container using ephemeral storage:

```sh
docker run --name %p \
  --publish 9200:9200 \
  --publish 9300:9300 \
  identakid/elasticsearch
```

Within the container the data (`/esvol/data`), log (`/esvol/logs`) and config (`/esvol/config`) directories are exposed as volumes so to start a default container with attached persistent/shared storage for data:

```sh
mkdir -p /es/data
docker run --rm --name %p
  --publish 9200:9200 \
  --publish 9300:9300 \
  --volume /es/data:/esvol/data \
  identakid/elasticsearch
```

Attaching persistent storage ensures that the data is retained across container restarts (with some obvious caveats). It is recommended this be done via a data container, preferably hosting an AWS S3 bucket or other externalized, distributed persistent storage.


### Available Features
A few plugins are installed namely:

- BigDesk: Provides live charts and statistics for an Elasticsearch cluster. You can open web browser and navigate to `http://localhost:9200/_plugin/bigdesk/` it will open Bigdesk and auto-connect to the ES node. You may need to change the `localhost` and `9200` port to the correct values for your environment/setup.

- Elasticsearch Head: A web front end for an Elasticsearch cluster. Open `http://localhost:9200/_plugin/head/` and it will run it as a plugin within the Elasticsearch cluster.

- Curator: Helps with management of indices. You can learn more at the Elasticsearch Curator documentation site `http://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html`.


### Configuring the environment (changing defaults)
The following environment variables can be used to configure the container using the Docker `-e` (or `--env`) flag:

  - `ES_NODE_NAME`  The name of node, is useful in production
  - `ES_RECOVER_AFTER_NODES`  Recover after how many nodes, is usful in production. Read more about `gateway.recover_after_nodes`
  - `ES_MINIMUM_MASTER_NODES`  Set the minimum number of master eligible nodes a node should "see" in order to win a master election. is usful in production. Read more about `discovery.zen.minimum_master_nodes`
  - `ES_CFG_URL`      Download external elasticsearch configuration file for use.
  - `ES_PORT`         Use to change from the default client port of 9200.
  - `ES_CLUSTER`      The name of the elasticsearch cluster, default is "es01".
  - `ES_PUBLISH_HOST` Set to any elasticsearch env variable, google: `elasticsearch network.publish_host`
  - `ES_DISCOVERY`    Set to "ec2" to enable AWS EC2 discovery, and also set AWS_ACCESS_KEY, AWS_SECRET_KEY, AWS_S3_BUCKET and AWS_REGION.
  - `AWS_REGION` Set aws region ex us-east-1, this is used also for ec2 discovery
  - `AWS_S3_BUCKET`   The AWS S3 bucket to use for snapshot backups.
  - `AWS_ACCESS_KEY`  The AWS access key to be used for discovery. Not required if the instance profile has ec2 DescribeInstance permissions.
  - `AWS_SECRET_KEY`  The AWS secret key to be used for discovery. Not required if the instance profile has ec2 DescribeInstance permissions.

  > Any port within a Docker image must be appropriately exposed (and mapped) on the Docker host. To avoid port conflicts, a _service discovery_ mechanism must be used and the correct hostname/ip and port on the Docker host passed to remote containers/hosts. Also, if using your own configuration file, you can either set the appropriate values within the file, or make use of variable substitution using the above (review the default file in the image for the expected format).


### Using external files
The following volumes are exposed for Docker host volume mounts using `-v` Docker command line option:

  - `/esvol/config`: Elasticsearch configuration file, `elasticsearch.yml`. The image also supports using a downloadable external configuration file specified via the `ES_CFG_URL` environment variable.
  - `/esvol/data`: Elasticsearch data files.
  - `/esvol/logs`: Elasticsearch log files.

  > The container must be able to access any URL provided, otherwise it will exit with a failure code.


### Service Discovery
Sample systemd unit files have been provided to show how service discovery could be achieved using this image, assuming the same is being done for the other components in the ELK stack. The examples use etcd and DNS as the service registries though there are other options.

Please refer to the appropriate systemd unit file for further details.
