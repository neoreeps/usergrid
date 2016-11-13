#!/bin/bash

# all parameters to this shell script are optional, defaults will be used otherwise
USERGRID_HOST=$1
ORG_NAME=$2
APP_NAME=$3
ADMIN_PASS=$4

dprint() {
    echo "`date` ---> ${@}" 2>&1
}

dprint "stop running docker containers"
docker stop $(docker ps --quiet)

dprint "remove existing container images"
docker rm -f usergrid cassandra elasticsearch portal

dprint "start containers"
docker run -d --name cassandra -p 9160:9160 -e CASSANDRA_START_RPC="true" -e JAVA_OPTS="-Xms128m -Xmx128m" -p 9042:9042 -v ${PWD}/ug-cassandra/data:/var/lib/cassandra neoreeps/ug-cassandra
docker run -d --name elasticsearch -v ${PWD}/ug-elasticsearch/data:/data -e ES_JAVA_OPTS="-Des.insecure.allow.root=true -Xms128m -Xmx128m" neoreeps/ug-elasticsearch
docker run -d --name usergrid -e ADMIN_PASS=${ADMIN_PASS} -e ORG_NAME=${ORG_NAME} -e APP_NAME=${APP_NAME} --link elasticsearch --link cassandra -p 8080:8080 -t neoreeps/usergrid
docker run -d --name portal -e USERGRID_HOST=${USERGRID_HOST} -p 80:80 neoreeps/ug-portal
