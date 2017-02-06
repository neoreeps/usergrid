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
docker stop cassandra elasticsearch usergrid portal

dprint "remove previous cassandra database"
sudo rm -rf ug-cassandra/data

dprint "remove existing containers"
docker rm -f usergrid cassandra elasticsearch portal

dprint "start cassandra"
docker run -d --name cassandra -e CASSANDRA_START_RPC="true" -e JAVA_OPTS="-Xms256m -Xmx512m" -v ${PWD}/ug-cassandra/data:/var/lib/cassandra neoreeps/ug-cassandra

dprint "start elasticsearch"
docker run -d --name elasticsearch -v ${PWD}/ug-elasticsearch/data:/data -e ES_JAVA_OPTS="-Des.insecure.allow.root=true -Xms256m -Xmx512m" neoreeps/ug-elasticsearch

while [ -z "$(docker logs cassandra |grep 'Listening for thrift clients')" ];
do
    echo "--> waiting for cassandra to finish starting"
    sleep 2
done

dprint "start usergrid"
docker run -d --name usergrid -e ADMIN_PASS=${ADMIN_PASS} -e ORG_NAME=${ORG_NAME} -e APP_NAME=${APP_NAME} --link elasticsearch --link cassandra -p 8080:8080 -t neoreeps/usergrid
dprint "start usergrid-portal"
docker run -d --name portal -e USERGRID_HOST=${USERGRID_HOST} -p 80:80 neoreeps/ug-portal
