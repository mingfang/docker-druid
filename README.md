docker-druid
============
Docker container running Master, Compute, Realtime, Broker, R/RStudio-Server, RDruid, MySql, Zookeeper, and Kafka.

Requirements:Docker

Build Docker image
==================
```bash
docker build -t druid .
```
or
```bash
./build
```

Run Container
=============
```bash
docker run -p 49083:8083 -p 49087:8787 -t -i druid /bin/bash
```
or
```bash
./shell
```

Note port 49083 forwards the Druid Rest API,
     port 49087 forwards the RStudio-Server

Inside the container, start the entire cluster
```bash
supervisord&
```

You may now follow the tutorial with step 4 here http://druid.io/docs/0.5.48/Loading-Your-Data.html

RStudio-Server
==============
Login at http://localhost:49087 
as user ```rstudio``` password ```rstudio```.
