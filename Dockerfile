FROM identakid/java:8u40-jre 
MAINTAINER identakid.com <ccssdev@identakid.com>

# Setup environment
ENV ES_VERSION 1.5.1
ENV ES_BASE /opt
ENV ES_HOME ${ES_BASE}/elasticsearch
ENV ES_VOL /esvol
ENV ES_EXEC /usr/local/bin/elasticsearch.sh
ENV ES_USER elasticsearch
ENV ES_GROUP elasticsearch

# Install requirements and Elasticsearch
WORKDIR ${ES_BASE}
RUN apt-get -yq update && DEBIAN_FRONTEND=noninteractive apt-get -yq install \
  curl \
  && apt-get -y clean && apt-get -y autoclean && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && curl -s https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz | tar zxf - \
  && ln -s elasticsearch-${ES_VERSION} elasticsearch

# Configure environment
COPY src/ /

RUN groupadd -r ${ES_GROUP} \
  && useradd -M -r -d ${ES_HOME} -g ${ES_GROUP} -c "Elasticsearch Service User" -s /bin/false ${ES_USER} \
  && mkdir -p ${ES_VOL}/data \
  && mkdir -p ${ES_VOL}/logs \
  && mkdir -p ${ES_VOL}/plugins \
  && mkdir -p ${ES_VOL}/work \
  && chown -R ${ES_USER}:${ES_GROUP} ${ES_HOME}/ ${ES_VOL} ${ES_EXEC} \
  && chmod +x ${ES_EXEC} \
  && ${ES_HOME}/bin/plugin -install elasticsearch/elasticsearch-cloud-aws/2.5.0 --silent --timeout 2m \
  && ${ES_HOME}/bin/plugin -install lukas-vlcek/bigdesk --silent --timeout 2m \
  && ${ES_HOME}/bin/plugin -install mobz/elasticsearch-head --silent --timeout 2m

# Expose volumes
VOLUME ["${ES_VOL}/data", "${ES_VOL}/config", "${ES_VOL}/logs"]

# Define working directory.
WORKDIR ${ES_VOL}

# Listen for 9200/tcp (HTTP) and 9300/tcp (cluster)
EXPOSE 9200 9300

# Start container
#USER ${ES_USER}
ENTRYPOINT ["/usr/local/bin/elasticsearch.sh"]
