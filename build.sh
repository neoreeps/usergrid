#!/bin/bash

DIRS="ug-cassandra  ug-elasticsearch  ug-java  ug-portal  usergrid"

for dir in $DIRS; do
    cd $dir
    BASENAME=`basename "${PWD}"`
    docker build -t neoreeps/${BASENAME} .
    cd ..
done
