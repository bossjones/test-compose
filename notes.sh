docker-machine create -d virtualbox mh-keystore
eval "$(docker-machine env mh-keystore)"
docker run -d     -p "8500:8500"     -h "consul"     progrium/consul -server -bootstrap
docker-machine create -d virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 2 --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-advertise=eth1:2376" mhs-demo0
docker-machine create -d virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 2 --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-advertise=eth1:2376" mhs-demo1
docker-machine create -d virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 2 --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-advertise=eth1:2376" mhs-demo2
eval $(docker-machine env --swarm mhs-demo2)
docker network create --driver overlay --subnet=10.0.9.0/24 my-net


https://docs.docker.com/engine/userguide/networking/get-started-overlay/

eval $(docker-machine env --swarm mhs-demo1)
docker-compose up -d
## if complains timeout...
## docker-compose stop
## docker-compose rm
## docker-compose up -d

docker exec -it mhs-demo0/sparkkafkadockerdemo2_mesos_slave_1 /usr/local/spark/bin/spark-shell --master mesos://mesos_master:5050

docker exec -it mhs-demo0/sparkkafkadockerdemo2_kafka_master_1 /opt/kafka_2.11-0.9.0.1/bin/kafka-topics.sh --create --zookeeper zk:2181 --replication-factor 1 --partitions 1 --topic test

docker exec -it mhs-demo0/sparkkafkadockerdemo2_kafka_master_1 /opt/kafka_2.11-0.9.0.1/bin/kafka-topics.sh --list --zookeeper zk:2181

docker exec -it mhs-demo1/testcompose_mesos_slave_1 /usr/local/spark/bin/run-example \
       org.apache.spark.examples.streaming.DirectKafkaWordCount zk:2181 \
       my-consumer-group test 1

docker exec -it mhs-demo1/testcompose_mesos_slave_1 python /pysparkFile/train.py /pysparkFile/train.csv

docker exec -it mhs-demo1/testcompose_mesos_slave_1 /usr/local/spark/bin/spark-submit --master mesos://mesos_master:5050 --class com.example.spark.DirectKafkaWordCount app/direct_kafka_word_count.jar kafka_master:9092 test


/usr/local/spark/bin/spark-submit --master local --class SimpleApp target/scala-2.10/simple-project_2.10-1.0.jar kafkaEvaluate kafka_master:9092 test2