FROM ubuntu:14.04
 
RUN apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#Install Oracle Java 7
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' > /etc/apt/sources.list.d/java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer

#Install Druid
RUN curl http://static.druid.io/artifacts/releases/druid-services-0.6.105-bin.tar.gz | tar xz 
RUN mv druid-services* druid-services

#MySQL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#Zookeeper
RUN curl http://www.us.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar xz
RUN mv zookeeper* zookeeper
RUN cd zookeeper && cp conf/zoo_sample.cfg conf/zoo.cfg

#Kafka
RUN wget http://archive.apache.org/dist/kafka/old_releases/kafka-0.7.2-incubating/kafka-0.7.2-incubating-src.tgz && \
    tar -xvzf kafka-*.tgz && \
    rm kafka-*.tgz && \
    mv kafka-0.7.2-incubating-src kafka && \
    cd kafka && \
    ./sbt update && ./sbt package

#Install R 
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' > /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base 

#RStudio Server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gdebi-core libapparmor1 libcurl4-openssl-dev
RUN wget http://download2.rstudio.org/rstudio-server-0.98.507-amd64.deb && \
    gdebi -n rstudio-server-0.98.507-amd64.deb && \
    rm rstudio-server-*-amd64.deb
RUN useradd -m rstudio && \
    echo "rstudio:rstudio" | chpasswd

#RDruid
RUN echo 'options("repos"="http://cran.us.r-project.org")' > /.Rprofile
RUN R -e "install.packages('devtools')"
RUN R -e "devtools::install_github('RDruid', 'metamx')"

#Add runit services
ADD sv /etc/service 

#Config

#Realtime ZK config
RUN echo '#zk\ndruid.zk.service.host=localhost\ndruid.server.maxSize=300000000000\ndruid.zk.paths.base=/druid' >> /druid-services/config/realtime/runtime.properties

#Init MySql
ADD ./mysql.ddl mysql.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < mysql.ddl && \
    mysqladmin shutdown


