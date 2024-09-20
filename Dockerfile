FROM ubuntu:latest

RUN apt update && \
    apt -y install maven openjdk-8-jdk && \
    apt install -y ssh pdsh openssh-server && \
    apt clean

RUN useradd -ms /bin/bash hadoopuser

ADD hadoop-3.3.5-src.tar.gz .

COPY package.json hadoop-3.3.5-src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp/package.json
RUN chown -R hadoopuser:hadoopuser /hadoop-3.3.5-src

USER hadoopuser
RUN cd hadoop-3.3.5-src && \
    mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true

USER root
RUN mv /hadoop-3.3.5-src/hadoop-dist/target/hadoop-3.3.5.tar.gz . && \
    tar -xvzf hadoop-3.3.5.tar.gz

RUN mv hadoop-3.3.5 /opt/hadoop && \
    rm -fr hadoop-3.3.5.tar.gz

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
