docker-druid
============
Docker container running Coordinator, Historical, Realtime, Broker, Overlord, R/RStudio-Server, RDruid, MySql, Zookeeper, and Kafka.

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
docker run -p 49083:8083 -p 49087:8787 -t -i -rm=true druid /bin/bash
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

You may now follow the tutorial here http://druid.io/docs/0.6.24/Tutorial:-Loading-Your-Data-Part-1.html

RStudio-Server
==============
Login at http://localhost:49087 
as user ```rstudio``` password ```rstudio```.
