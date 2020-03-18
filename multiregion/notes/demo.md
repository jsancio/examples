# Review of features

Offset preserving replication
Async or Sync Replication
Automatic client failover

# What has change since the preview?

The name changed: Multi-Region Clusters

Monitoring in C3 is easier

Better replica status tooling

Altering replica placement is different

1. Alter the config
root@broker-west-1:/# root@broker-west-1:/# kafka-configs --zookeeper zookeeper-west:2181 --entity-name multi-region-async --entity-type topics --alter --add-config confluent.placement.constraints=/etc/kafka/demo/placement-multi-region-sync.json


2. Execute the plan
root@broker-west-1:/# confluent-rebalancer execute --bootstrap-server broker-west-1:19091 --metrics-bootstrap-server broker-west-1:19091 --zookeeper zookeeper-west:2181 --throttle 10000000 --verbose


3. Finish the rebalance
root@broker-west-1:/# confluent-rebalancer finish --zookeeper zookeeper-west:2181

# Docs
go/multi-region-docs

# Who's using Multi-Region Clusters
go/mrr-feedback



# Failback is different

`auto.leader.rebalance.enable`
`leader.imbalance.per.broker.percentage`
`leader.imbalance.check.interval.seconds`
