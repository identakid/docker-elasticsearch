## ElasticSearch Dockerfile

This repository contains a **Dockerfile** of [ElasticSearch](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/cgswong/elasticsearch/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

It is usually the back-end for a Logstash instance with Kibana as the frontend.

### Base Docker Image

* [cgswong/java:orajdk8](https://registry.hub.docker.com/u/cgswong/java/) which is based on [cgswong/min-jessie](https://registry.hub.docker.com/u/cgswong/min-jessie/)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/cgswong/elasticsearch/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cgswong/elasticsearch`

   (alternatively, you can build an image from Dockerfile: `docker build -t="cgswong/elasticsearch" github.com/cgswong/docker-elasticsearch`)

### Usage
To start a basic container with ephemeral storage:

```sh
docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch cgswong/elasticsearch
```

Within the container the data (/esvol/data), log (/esvol/logs) and config (/esvol/config) directories are exposed as volumes so to start a default container with attached persistent/shared storage for data:

```sh
mkdir -p /es/data
docker run -d -p 9200:9200 -p 9300:9300 -v /es/data:/esvol/data --name elasticsearch cgswong/elasticsearch
```

Attaching persistent storage ensures that the data is retained across container restarts (with some obvious caveats). At this time though, given the state of maturity in this space, I would recommend this be done via a data container (hosting an AWS S3 bucket or other externalized, distributed persistent storage) in a possible production environment.

#### Changing Defaults
A few environment variables can be passed via the Docker `-e` flag to do some further configuration:

- ES_CLUSTER: Sets the cluster name (defaults to es01)
- ES_CONF: Sets the location of the ES configuration file.
- ES_PORT_9200_TCP_ADDR: Sets the ES port (defaults to 9200) which is in the format expected when using the alias `es` for this container in a linked container setup.
