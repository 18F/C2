#!/bin/sh

set -x
set -e

ES_VERSION=1.7.4
TAR_FILE=elasticsearch-$ES_VERSION.tar.gz

if [ ! -e elasticsearch/bin/elasticsearch ]; then
  wget http://download.elasticsearch.org/elasticsearch/elasticsearch/$TAR_FILE
  tar xzf $TAR_FILE
  mv elasticsearch-$ES_VERSION elasticsearch
fi
