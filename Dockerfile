FROM ubuntu:latest

RUN apt update && \
    apt -y install openjdk-8-jdk && \
    apt install -y ssh pdsh openssh-server && \
    apt clean

ADD hadoop-3.3.6.tar.gz .
RUN mv hadoop-3.3.6 /opt/hadoop && \
    rm -fr hadoop-3.3.6.tar.gz

RUN useradd -ms /bin/bash hadoopuser
RUN chown -R hadoopuser:hadoopuser /opt/hadoop
    
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY entrypoint.sh /entrypoint.sh
COPY sshd_config /etc/ssh/sshd_config

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
