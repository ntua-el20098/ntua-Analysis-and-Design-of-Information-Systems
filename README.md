
# Distributed Execution of SQL Queries using PrestoDB (Information Systems - NTUA)

## Overview
[PrestoDB](https://prestodb.io/) is a distributed SQL query engine designed to handle large-scale data analysis by querying data across heterogeneous data sources. This project aims to benchmark the performance of **PrestoDB** across a <ins>different query types, data locations and number of presto workers</ins> in our configuration, using three different underlying data storage systems: **PostgreSQL**, **MongoDB** and **Cassandra**. 

To create a highly portable, cloud-based environment, **Docker containers** will be employed to deploy PrestoDB and each data storage system. These containers will operate on an **overlay virtual network** spanning multiple hosts which are nodes of a docker swarm, simulating distributed deployments of services. By leveraging Docker, the project ensures scalability, easy orchestration, and cloud-native compatibility, making it straightforward to replicate and extend the benchmarking setup in various environments, including private or public cloud platforms.

This project not only benchmarks PrestoDB's capabilities but also provides a practical, cloud-ready framework to evaluate distributed SQL query engines in a heterogeneous data ecosystem.

## Table of Contents

 - [Set up & Configuration](#Set-up-&-Configuration)
	 - [Docker installation](#Docker-installation)
	 - [Docker Swarm](#Docker-Swarm)
	 - [Overlay Network](#Overlay-Network) 
	 - [Presto Docker container](#Presto-Docker-container)
	 - [Connect Databases to PrestoDB](#Connect-Databases-to-PrestoDB)
	 - [Workers](#Workers)
	 - [Docker-Compose](#Docker-Compose)
	 - [Summary and Visualization of our configuration](#Summary-and-Visualization-of-our-configuration)
 - [TPC-DS Data Loading](#TPC-DS-Data-Loading)
 - [Benchmarking](#Benchmarking)
 - [Figures](#Figures)
 
## Set up & Configuration

Three different host machines will be used for our configuration. For the purpose of this README file we will call them     nodes 1, 2, 3.

### 🐳Docker installation
-----------------
*The following steps should be applied to all of the hosts(3 in our project) participating with their own docker container(s) in the cluster.* 

First, update your existing list of packages:

	$ sudo apt update

Next, install a few prerequisite packages which let `apt` use packages over HTTPS:

	$ sudo apt install apt-transport-https ca-certificates curl software-properties-common

Then add the GPG key for the official Docker repository to your system:
	
	$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

Add the Docker repository to APT sources:

    $ echo "deb [arch=$(dpkg --print-architecture) \ 
    signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \ 
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \ 
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Update your existing list of packages again for the addition to be recognized:

    $ sudo apt update

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

    $ apt-cache policy docker-ce



Notice that `docker-ce` is not installed, but the candidate for installation is from the Docker repository for Ubuntu 22.04 (`jammy`).

Finally, install Docker:

    $ sudo apt install docker-ce

Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it’s running:

    $ sudo systemctl status docker

The output should be similar to the following, showing that the service is active and running:

    Output
    ● docker.service - Docker Application Container Engine
         Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
         Active: active (running) since Fri 2022-04-01 21:30:25 UTC; 22s ago
    TriggeredBy: ● docker.socket
           Docs: https://docs.docker.com
       Main PID: 7854 (dockerd)
          Tasks: 7
         Memory: 38.3M
            CPU: 340ms
         CGroup: /system.slice/docker.service
                 └─7854 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Installing Docker now gives you not just the Docker service (daemon) but also the `docker` command line utility, or the Docker client.

After these steps we have successfully installed the same version of docker(27.4.1) to all of the nodes in our configuration.

### Docker Swarm
_________________
To initialize docker swarm on our main node(node 1), where PrestoDB coordinator container will be deployed,  we run the following command : 

    docker swarm init --advertise-addr 2001:648:2ffe:501:cc00:13ff:fea7:ddf9
    
the output of the command will be something like this:
```console
Swarm initialized: current node (bvz81updecsj6wjz393c09vti) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3ds6329crye714vjq046ycvv8uejb2khr60j63eqorrj25dkre-2jorol2ys56auw6ndbuvmeh64  [2001:648:2ffe:501:cc00:13ff:fea7:ddf9]:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```

Now we can add more nodes to our swarm. Specifically, we added the node 2 that will host the PostgreSQL database container and the node 3 that will host the Cassandra database container using on both machines the command:

    docker swarm join --token <token-id> [2001:648:2ffe:501:cc00:13ff:fea7:ddf9]:2377
    
### Overlay Network
___________
Now it is time to create a docker overlay network named "overnet" using the following command:

    docker network create -d overlay overnet
  
This will be useful later on so we can achieve communication between the presto and databases using the VLAN network abstraction of overlay docker network.

*From now on we assume you have created a project directory on your main node(1) in which the `docker-compose.yaml` file will run and the necessary containers with their necessary configuration files will be deployed to every other node as services.* 

###  Presto Docker container
___________________________

 1. Download the latest non-edge Presto container from [Presto on DockerHub](https://hub.docker.com/r/prestodb/presto/tags). Run the following command:
    
    `docker pull prestodb/presto:latest`
    
    Downloading the container may take a few minutes. When the download completes, go on to the next step.
    
2.  On your repository, create a file named `./docker-presto-integration/coordinator/config.properties` containing the following text:

	    coordinator=true
	    node-scheduler.include-coordinator=true
	    http-server.http.port=8080
	    query.max-memory=5GB
	    query.max-memory-per-node=1GB
	    query.max-stage-count=150
	    discovery-server.enabled=true
	    discovery.uri=http://localhost:8080
	    
	    # spill is used on sf10 dataset
	    spill-enabled=true
	    spiller-spill-path=/var/presto/data/spill
	    	    
	This file is mounted into `/opt/presto-server/etc/config.properties`
    
3.  On your repository, create a file named `./docker-presto-integration/coordinator/jvm.config` containing the following text:

	    -server
	    # Change this to 76-85% of the total memory of your node 
	    -Xmx6G
	    -XX:InitialRAMPercentage=80
	    -XX:MaxRAMPercentage=80
	    -XX:G1HeapRegionSize=32M
	    -XX:+ExplicitGCInvokesConcurrent
	    -XX:+ExitOnOutOfMemoryError
	    -XX:+HeapDumpOnOutOfMemoryError
	    -XX:-OmitStackTraceInFastThrow
	    -XX:ReservedCodeCacheSize=512M
	    -XX:PerMethodRecompilationCutoff=10000
	    -XX:PerBytecodeRecompilationCutoff=10000
	    -Djdk.attach.allowAttachSelf=true
	    -Djdk.nio.maxCachedBufferSize=2000000
	    -XX:+UnlockDiagnosticVMOptions
	    -Dfile.encoding=UTF-8
	    -XX:+UseAESCTRIntrinsics
	    
	This file is mounted into `/opt/presto-server/etc/jvm.config`
	
4.  On your repository, create a file named `./docker-presto-integration/coordinator/node.properties` containing the following content:

	    node.environment=production
	    node.id=coordinator
	    node.data-dir=/var/presto/data
	    
	This file is mounted into `/opt/presto-server/etc/node.properties`

### Connect Databases to PrestoDB
To add PostgreSQL, MongoDB and Cassandra to PrestoDB catalog we mount the directory `./docker-presto-integration/config/catalog` into `/opt/presto-server/etc/catalog` of the <ins>coordinator</ins> Presto container.
In detail this directory contains the following files :

**postgresql.properties**
 
    connector.name=postgresql
    connection-url=jdbc:postgresql://presto_postgresql:5432/presto
    connection-user=root
    connection-password=presto

**cassandra.properties**

    connector.name=cassandra
    cassandra.contact-points=presto_cassandra
    cassandra.native-protocol-port=9042

**mongodb.properties**

    connector.name=mongodb
    mongodb.seeds=presto_mongodb:27017

### Workers
_________________________
As mentioned before we have to test our distributed query engine with different number of workers. These workers are deployed from the same docker image as Presto coordinator but will run on different nodes and different `config.properties` and `node.properties` files will be mounted into their respective directories.

**config.properties**

    # config.properties content - for the workers 
    coordinator=false
    http-server.http.port=8080
    
    discovery.uri=http://presto:8080
    
    # spill is used on sf10 dataset
    spill-enabled=true
    spiller-spill-path=/var/presto/data/spill
    
**node.properties**

	node.environment=production
	node.id=worker_<worker_number>
	node.data-dir=/var/lib/presto/data

An important detail is that in any configuration of workers tested **one of the workers will always be the coordinator Presto container** which is configured to work both as coordinator and worker e.g. For three active workers we will have the PrestoDB coordinator and 2 more Presto container with the files of this section mounted into their appropriate directories.

### Docker-Compose
----------------------------------
After successfully completing the previous steps the docker-compose.yaml in the `./docker-presto-integration/` should deploy successfully the Presto coordinator, all the databases and the Presto workers needed(based on our Benchmarking approach). To deploy run : 

    docker stack deploy -c docker-compose.yaml presto 
    
 on the node 1 (main node of our system).

### Summary and Visualization of our configuration
---------------------------------------------
On **node 1 we will deploy MongoDB and PrestoDB coordinator**, also acting as worker, on **node 2 we will deploy the PostgreSQL  database and node 3 the Cassandra database**. A visualization of the physical topology of our system is shown below: 
![network diagram drawio](https://github.com/user-attachments/assets/1539f892-1b88-4ed8-8449-74573d9f564b)

The VLAN of docker overlay network turns our configuration into something simpler and more abstract as you can see in the figure below:


![dockernetwork drawio](https://github.com/user-attachments/assets/b836663a-e383-4310-879c-3d21f6317ca5)

## TPC-DS Data Loading
We performed ExtractTransferLoad(ETL) using the [TPC-DS connector](https://prestodb.io/docs/current/connector/tpcds.html) by mounting the catalog properties file in `docker-presto-integration/config/catalog` into `etc/catalog/tpcds.properties` with the following contents:

    connector.name=tpcds

 We utilized the `CREATE TABLE AS SELECT` query provided by presto create and populate the tables.
 
We loaded the data using the following command for postgresql, mongodb and cassandra for sf1 and sf10.

    docker exec -it presto presto-cli --server presto:8080 --catalog <db_name> --schema <sfx> --file /opt/presto-server/etc/tpcds_to_<dbname>.sql

## Benchmarking
For the benchmarking the [benchmark driver](https://prestodb.io/docs/current/installation/benchmark-driver.html) provided by Presto was used. Following the steps in the documentation of presto version 0.290 we downloaded the jar file in the directory `docker-presto-integration/coordinator` and mounted it into the `/opt/benchmark-driver/presto-benchmark-driver`  of our presto-coordinator container running on the main node of our swarm. Specifically, 

**suite.json**

    {
      "tpcds_<dbname>_sf<size>": {
        "query": ["Q.*"],
        "schema": ["<schema_of_db_used>"],
        "session": {}
      }
      
    }

**Command**

 `./presto-benchmark-driver --catalog <catalog> --runs 3 --warm 2 \ --suite <tpcds_<dbname>_sf<size>>`

## Figures 
The script for generating figures is `results.ipynb` located in `./results` The `.txt` benchmark files generated by the **presto-benchmark-driver** are located in the same directory, while the generated figures are stored in `./plots`. 






