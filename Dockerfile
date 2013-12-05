FROM ubuntu

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat

#Install Oracle Java 7
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main' > /etc/apt/sources.list.d/java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer

#Install Druid
RUN wget http://static.druid.io/artifacts/releases/druid-services-0.6.25-bin.tar.gz && \
    tar -zxf druid-services-*.gz && \
    mv druid-services-0.6.25 druid-services && \
    rm druid-services-*.gz

#MySQL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#Zookeeper
RUN wget http://www.motorlogy.com/apache/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz && \
    tar xzf zookeeper-*.tar.gz && \
    rm zookeeper-*.tar.gz && \
    mv zookeeper-3.4.5 zookeeper && \
    cd zookeeper && \
    cp conf/zoo_sample.cfg conf/zoo.cfg && \
    rm -rf docs src

#Kafka
RUN wget http://archive.apache.org/dist/kafka/old_releases/kafka-0.7.2-incubating/kafka-0.7.2-incubating-src.tgz && \
    tar -xvzf kafka-*.tgz && \
    rm kafka-*.tgz && \
    mv kafka-0.7.2-incubating-src kafka && \
    cd kafka && \
    ./sbt update && ./sbt package

#Install R 3+
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu precise/' > /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base libcurl4-openssl-dev
RUN echo 'options("repos"="http://cran.us.r-project.org")' > /.Rprofile
RUN R -e "install.packages('devtools')"
#RDruid
RUN R -e "devtools::install_github('RDruid', 'metamx')"
#RStudio Server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sudo gdebi-core libapparmor1
RUN wget http://download2.rstudio.org/rstudio-server-0.97.551-amd64.deb && \
    gdebi -n rstudio-server-0.97.551-amd64.deb && \
    rm rstudio-server-0.97.551-amd64.deb
RUN useradd -m rstudio && \
    echo "rstudio:rstudio" | chpasswd


#Config

#Realtime ZK config
RUN echo '#zk\ndruid.zk.service.host=localhost\ndruid.server.maxSize=300000000000\ndruid.zk.paths.base=/druid' >> /druid-services/config/realtime/runtime.properties
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Init MySql
ADD ./mysql.ddl mysql.ddl
RUN mysqld & sleep 3 && \
    mysql < mysql.ddl && \
    mysqladmin shutdown


