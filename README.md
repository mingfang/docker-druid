docker-druid
============
Docker container running Master, Compute, Realtime, Broker, R, DDruid, MySql, Zookeeper, and Kafka.

Requirements:Docker

Build Docker image
```bash
docker build -t druid .
```

Run Container
```bash
docker run -t -i druid /bin/bash
```

Inside the container, start the entire cluster
```bash
supervisord&
```

You may now follow the tutorial with step 4 here http://druid.io/docs/0.5.48/Loading-Your-Data.html
