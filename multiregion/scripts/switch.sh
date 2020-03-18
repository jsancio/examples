#!/bin/bash

echo -e "\n==> Create topic multi-region-async with replica placement constraint\n"
docker-compose exec broker-west-1 kafka-topics  \
	--create \
	--bootstrap-server broker-west-1:19091 \
	--topic multi-region-async \
	--partitions 1 \
	--replica-placement /etc/kafka/demo/placement-multi-region-async.json \
	--config min.insync.replicas=1

echo -e "\n==> Describe topic multi-region-async\n"
docker-compose exec broker-east-3 kafka-topics \
	--describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-async

echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions

echo -e "\n==> Shutdown broker-west-1 and broker-west-2\n"
docker-compose stop broker-west-1
docker-compose stop broker-west-2

echo -e "\n==> Wait for 10 seconds for update metadata to propagate\n"
sleep 10

echo -e "\n==> Partition should be unavailable.\n"
docker-compose exec broker-east-3 kafka-topics --describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-async

echo -e "\n==> Perform unclean leader elction.\n"
docker-compose exec broker-east-3 kafka-leader-election \
	--bootstrap-server broker-east-3:19093 \
	--topic multi-region-async \
	--partition 0 \
	--election-type unclean

echo -e "\n==> Partition should be available.\n"
docker-compose exec broker-east-3 kafka-topics --describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-async

echo -e "\n==> Switching replica placements\n"
docker-compose exec broker-east-3 kafka-configs \
	--bootstrap-server broker-east-3:19093 \
	--alter --topic multi-region-async \
	--replica-placement /etc/kafka/demo/placement-multi-region-async-reverse.json

echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions

echo -e "\n==> Running Balance\n"
docker-compose exec broker-east-3 confluent-rebalancer proposed-assignment \
	--metrics-bootstrap-server broker-east-3:19093 \
	--bootstrap-server broker-east-3:19093 \
	--replica-placement-only \
	--topics multi-region-async

docker-compose exec broker-east-3 confluent-rebalancer execute \
	--metrics-bootstrap-server broker-east-3:19093 \
	--bootstrap-server broker-east-3:19093 \
	--replica-placement-only \
	--force \
	--throttle 10000000

docker-compose exec broker-east-3 confluent-rebalancer finish \
	--bootstrap-server broker-east-3:19093


echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions

echo -e "\n==> Start broker-west-1 and broker-west-2\n"
docker-compose start broker-west-1
docker-compose start broker-west-2

echo -e "\n==> Wait for 10 seconds for update metadata to propagate\n"
sleep 10

echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions
