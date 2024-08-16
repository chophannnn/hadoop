FROM ubuntu:22.04

LABEL author="Cho Phan"

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop

RUN \
  apt-get update \
  && apt-get install -y \
    sudo \
    openssl

RUN \
  sudo useradd -m -s /bin/bash -p $(openssl passwd -1 chophan) hadoop \
  && sudo usermod -aG sudo hadoop \
  && sudo su - hadoop

USER hadoop

RUN \
  echo "chophan" | sudo -S apt-get install -y \
    vim \
    wget \
    openjdk-8-jdk \
    ssh \
    iputils-ping

RUN mkdir -p /home/hadoop/Downloads

WORKDIR /home/hadoop/Downloads

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz

RUN tar -zxvf hadoop-3.3.6.tar.gz

RUN echo "chophan" | sudo -S mv hadoop-3.3.6 $HADOOP_HOME

WORKDIR $HADOOP_HOME

RUN echo "chophan" | sudo -S rm -R /home/hadoop/Downloads

RUN \
  echo "\nexport JAVA_HOME=$JAVA_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$JAVA_HOME/bin\n' >> ~/.bashrc \
  && echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin\n' >> ~/.bashrc

RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

RUN \
  mkdir -p \
    $HADOOP_HOME/data/hdfs/namenode \
    $HADOOP_HOME/data/hdfs/datanode \
    $HADOOP_HOME/tmp \
    $HADOOP_HOME/logs

COPY /conf/ $HADOOP_HOME/etc/hadoop/
COPY /start-hadoop.sh $HADOOP_HOME/

RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
  && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys

ENTRYPOINT ["/bin/bash", "./start-hadoop.sh"]
