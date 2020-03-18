#!/bin/bash

echo -e "\n==> Create topic multi-region-default with the topic configuration default\n"
read -p "Press any key to continue..."
docker-compose exec broker-west-1 kafka-topics  \
	--create \
	--bootstrap-server broker-west-1:19091 \
	--topic multi-region-default \

echo -e "\n==> Describe topic multi-region-default\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-topics \
	--describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-default

echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions

echo -e "\n==> Shutdown broker-west-1 and broker-west-2\n"
read -p "Press any key to continue..."
docker-compose stop broker-west-1
docker-compose stop broker-west-2

echo -e "\n==> Wait for 10 seconds for update metadata to propagate\n"
sleep 10

echo -e "\n==> Partition should be unavailable.\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-topics \
	--describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-default

echo -e "\n==> Perform unclean leader election.\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-leader-election \
	--bootstrap-server broker-east-3:19093 \
	--topic multi-region-default \
	--partition 0 \
	--election-type unclean

echo -e "\n==> Partition should be available.\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-topics \
	--describe \
        --bootstrap-server broker-east-3:19093 \
	--topic multi-region-default

echo -e "\n==> Switching replica placement constraints\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-configs \
	--bootstrap-server broker-east-3:19093 \
	--alter --topic multi-region-default \
	--replica-placement /etc/kafka/demo/placement-multi-region-async-reverse.json

echo -e "\n==> Show the new replica placement configuration\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--topic multi-region-default

echo -e "\n==> Running Confluent Rebalancer\n"
read -p "Press any key to continue..."
docker-compose exec broker-east-3 confluent-rebalancer proposed-assignment \
	--metrics-bootstrap-server broker-east-3:19093 \
	--bootstrap-server broker-east-3:19093 \
	--replica-placement-only \
	--topics multi-region-default

docker-compose exec broker-east-3 confluent-rebalancer execute \
	--metrics-bootstrap-server broker-east-3:19093 \
	--bootstrap-server broker-east-3:19093 \
	--replica-placement-only \
	--topics multi-region-default \
	--force \
	--throttle 10000000

docker-compose exec broker-east-3 confluent-rebalancer finish \
	--bootstrap-server broker-east-3:19093

echo -e "\n==> Show the new replica placement configuration\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--topic multi-region-default

echo -e "\n==> Start broker-west-1 and broker-west-2\n"
read -p "Press any key to continue..."
docker-compose start broker-west-1
docker-compose start broker-west-2

echo -e "\n==> Wait for 10 seconds for update metadata to propagate\n"
sleep 10

echo -e "\n==> Paritions with Invalid Replica Placement Constraints\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--invalid-replica-placement-partitions

echo -e "\n==> Show the new replica placement configuration\n"
docker-compose exec broker-east-3 kafka-topics \
	--bootstrap-server broker-east-3:19093 \
	--describe \
	--topic multi-region-default
