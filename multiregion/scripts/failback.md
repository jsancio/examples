ok, so to have more manual control over the failover process do the following
steady.json
{
    "version": 1,
    "replicas": [
        {
            "count": 2,
            "constraints": {
                "rack": "nj"
            }
        }
    ],
    "observers": [
        {
        "count": 2,
            "constraints": {
                "rack": "chi"
            }
        }
    ]
}
failover to the observers using unclean leader election
change the the replica placement be doing the following
1. Alter the config
root@broker-west-1:/# root@broker-west-1:/# kafka-configs --zookeeper zookeeper-west:2181 --entity-name multi-region-async --entity-type topics --alter --add-config confluent.placement.constraints=/etc/kafka/demo/failed.json
2. Execute the plan
root@broker-west-1:/# confluent-rebalancer execute --bootstrap-server broker-west-1:19091 --metrics-bootstrap-server broker-west-1:19091 --zookeeper zookeeper-west:2181 --throttle 10000000 --verbose
3. Finish the rebalance
root@broker-west-1:/# confluent-rebalancer finish --zookeeper zookeeper-west:2181
failed.json
{
    "version": 1,
    "replicas": [
        {
            "count": 2,
            "constraints": {
                "rack": "chi"
            }
        }
    ],
    "observers": [
        {
        "count": 2,
            "constraints": {
                "rack": "nj"
            }
        }
    ]
}
Now bring up the brokers in NJ
do a failover back the the NJ observers
repeat the alter configs and ADB sequence in the reverse direction





now with all that said, I don’t recommend doing all of this.  My recommendation is to allow the system to do it’s thing
run unclean leader election back to failover to the observers when the brokers fail
restart the apps in the other DC.  Teams can do this on their down if they want or if it’s only a partial failover live with the cross DC traffic for a bit
get the brokers back online
the system will get back to homeostatis automatically but running PREFERRED leader election might be required if the leader imbalance ration is too high
all the apps to restart in the other data centers in time 
the later is much easier IMO
