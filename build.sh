#!/bin/bash

DIRS="ug-java  ug-cassandra  ug-elasticsearch  ug-portal  usergrid"

for dir in $DIRS; do
    echo -e "\n-->> Building ${dir} ...\n"
    cd $dir
    BASENAME=`basename "${PWD}"`
    docker build -t neoreeps/${BASENAME} .
    cd ..
done
