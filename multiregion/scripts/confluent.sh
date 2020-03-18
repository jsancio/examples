#!/bin/bash

function west-failure() {
    docker-compose kill zookeeper-west-1 zookeeper-west-2 zookeeper-west-3 broker-west-1
    echo -e '\n==> West coast datacenter failure. Run confluent.sh failover\n'
}

function failover() {
    echo -e '\n==> Moving ZK Quorum to backup DC\n'
    sed -i "" 's|ZOOKEEPER_PEER_TYPE: observer|# ZOOKEEPER_PEER_TYPE: observer|' /Users/addison.huddy/Dropbox/kafka-home/examples/multiregion/docker-compose.yml
    
    sed -i "" 's|ZOOKEEPER_SERVERS: zookeeper-west-1:2888:3888;zookeeper-west-2:2888:3888;zookeeper-west-3:2888:3888;zookeeper-east-1:2888:3888:observer;zookeeper-east-2:2888:3888:observer;zookeeper-east-3:2888:3888:observer|ZOOKEEPER_SERVERS: zookeeper-west-1:2888:3888:observer;zookeeper-west-2:2888:3888:observer;zookeeper-west-3:2888:3888:observer;zookeeper-east-1:2888:3888;zookeeper-east-2:2888:3888;zookeeper-east-3:2888:3888|' /Users/addison.huddy/Dropbox/kafka-home/examples/multiregion/docker-compose.yml

    echo -e '\n==> Restarting zookeeper nodes\n'
    docker-compose create zookeeper-east-1 zookeeper-east-2 zookeeper-east-3
    docker-compose restart zookeeper-east-1 zookeeper-east-2 zookeeper-east-3

    echo -e '\n> ZK Quorom Restored\n'
}

function failback() {
    echo -e '\n==> Resetting ZK Ouorom to the West Coast\n'
    
    sed -i "" 's|# ZOOKEEPER_PEER_TYPE: observer|ZOOKEEPER_PEER_TYPE: observer|' /Users/addison.huddy/Dropbox/kafka-home/examples/multiregion/docker-compose.yml

    sed -i "" 's|ZOOKEEPER_SERVERS: zookeeper-west-1:2888:3888:observer;zookeeper-west-2:2888:3888:observer;zookeeper-west-3:2888:3888:observer;zookeeper-east-1:2888:3888;zookeeper-east-2:2888:3888;zookeeper-east-3:2888:3888|ZOOKEEPER_SERVERS: zookeeper-west-1:2888:3888;zookeeper-west-2:2888:3888;zookeeper-west-3:2888:3888;zookeeper-east-1:2888:3888:observer;zookeeper-east-2:2888:3888:observer;zookeeper-east-3:2888:3888:observer|' /Users/addison.huddy/Dropbox/kafka-home/examples/multiregion/docker-compose.yml

    docker-compose create zookeeper-east-1 zookeeper-east-2 zookeeper-east-3

    docker-compose restart zookeeper-west-1 zookeeper-west-2 zookeeper-west-3 \
                           zookeeper-east-1 zookeeper-east-2 zookeeper-east-3

    docker-compose restart broker-west-1
}

"$@"



