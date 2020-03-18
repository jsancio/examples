Make sure to set `KAFKA_AUTO_LEADER_REBALANCE_ENABLE: 'false'`

Broker stop working in nj

Unclean leader election
`$ kafka-leader-election --bootstrap-server broker-east-4:19094 --election-type UNCLEAN --topic foo --partition 0`

Restart applications in the other data center if required to avoid cross region traffic

`$ kafka-leader-election --bootstrap-server broker-east-4:19094 --election-type PREFERRED --topic foo --partition 0`

Restart applications in the first data center if required to avoid cross region traffic