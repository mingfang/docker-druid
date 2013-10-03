FROM ubuntu

RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list
RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list
RUN apt-get update

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN apt-get install -y openssh-server && mkdir /var/run/sshd && echo 'root:root' |chpasswd

#Utilities
RUN apt-get install -y vim less ntp net-tools inetutils-ping curl git

#Install Oracle Java 7
RUN apt-get install -y python-software-properties && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

#Install Druid
RUN curl -O http://static.druid.io/artifacts/releases/druid-services-0.5.54-bin.tar.gz && \
    tar -zxvf druid-services-*-bin.tar.gz && \
    rm druid-services-*-bin.tar.gz

#MySQL
RUN apt-get install -y mysql-server python-mysqldb && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#Zookeeper
RUN curl http://www.motorlogy.com/apache/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz -o zookeeper-3.4.5.tar.gz && \
    tar xzf zookeeper-3.4.5.tar.gz && \
    cd zookeeper-3.4.5 && \
    cp conf/zoo_sample.cfg conf/zoo.cfg && \
    rm /zookeeper-3.4.5.tar.gz

#Kafka
RUN wget http://apache.spinellicreations.com/incubator/kafka/kafka-0.7.2-incubating/kafka-0.7.2-incubating-src.tgz && \
    tar -xvzf kafka-0.7.2-incubating-src.tgz && \
    rm kafka-0.7.2-incubating-src.tgz && \
    cd kafka-0.7.2-incubating-src && \
    ./sbt update && ./sbt package

#Install R 3+
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu precise/' > /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update
RUN apt-get install -y r-base libcurl4-openssl-dev
RUN echo 'options("repos"="http://cran.us.r-project.org")' > /.Rprofile
RUN R -e "install.packages('devtools')"
#RDruid
RUN R -e "devtools::install_github('RDruid', 'metamx')"
#RStudio Server
RUN apt-get install -y sudo gdebi-core libapparmor1
RUN wget http://download2.rstudio.org/rstudio-server-0.97.551-amd64.deb && \
    gdebi -n rstudio-server-0.97.551-amd64.deb && \
    rm rstudio-server-0.97.551-amd64.deb
RUN useradd -b /home -m -p rstudio rstudio

#Config
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Init MySql
ADD ./mysql.ddl mysql.ddl
RUN mysqld & sleep 3 && \
    mysql < mysql.ddl && \
    mysqladmin shutdown

#Realtime ZK config
RUN echo '#zk\ndruid.zk.service.host=localhost\ndruid.server.maxSize=300000000000\ndruid.zk.paths.base=/druid' >> /druid-services-0.5.54/config/realtime/runtime.properties

