#!/bin/bash

echo -e "\n\n==> Produce: Multi-region Async Replication to Observers (topic: multi-region-async) \n"

docker-compose exec broker-west-1 kafka-producer-perf-test --topic multi-region-async \
	--num-records 5000000 \
	--record-size 5000 \
	--throughput 10 \
	--producer-props \
	acks=all \
	bootstrap.servers=broker-west-1:19091,broker-east-3:19093 \
	compression.type=none \
        batch.size=8196
