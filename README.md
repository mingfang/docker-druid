docker-druid
============
Docker container running Coordinator, Historical, Realtime, Broker, Overlord, R/RStudio-Server, RDruid, MySql, Zookeeper, and Kafka.

Requirements:Docker

Build Docker image
==================
```bash
./build
```

Run Container
=============
```bash
./shell
```

Note port 8083 forwards the Druid Rest API,
     port 8087 forwards the RStudio-Server

Inside the container, start the entire cluster
```bash
runsvdir-start&
```

You may now follow the tutorial here http://druid.io/docs/0.6.105/Tutorial:-Loading-Your-Data-Part-1.html

RStudio-Server
==============
Login at http://localhost:49087 
as user ```rstudio``` password ```rstudio```.
