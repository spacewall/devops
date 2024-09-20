#!/bin/bash

service ssh start

su - hadoopuser -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys  && \
chown 0600 ~/.ssh/authorized_keys"

service ssh restart

su - hadoopuser -c "$HADOOP_HOME/bin/hdfs namenode -format"
su - hadoopuser -c "mkdir -p /tmp/hadoop-hadoopuser/dfs/name"
su - hadoopuser -c "$HADOOP_HOME/sbin/start-dfs.sh"
su - hadoopuser -c "$HADOOP_HOME/sbin/start-yarn.sh"

tail -f /dev/null
