# Distributed Execution of SQL Queries using PrestoDB (Information Systems - NTUA)

## Overview
[PrestoDB](https://prestodb.io/) is a distributed SQL query engine designed to handle large-scale data analysis by querying data across heterogeneous data sources. This project aims to benchmark the performance of PrestoDB across a variety of query types and data locations, using three different underlying data storage systems: **PostgreSQL**, **MongoDB**, and **Cassandra**.

To create a highly portable, cloud-based environment, **Docker containers** will be employed to deploy PrestoDB and each data storage system. These containers will operate on an **overlay virtual network** spanning multiple hosts, simulating distributed deployments. By leveraging Docker, the project ensures scalability, easy orchestration, and cloud-native compatibility, making it straightforward to replicate and extend the benchmarking setup in various environments, including private or public cloud platforms.

This project not only benchmarks PrestoDB's capabilities but also provides a practical, cloud-ready framework to evaluate distributed SQL query engines in a heterogeneous data ecosystem.

## Bookmarks

 - Docker installation
 - TPCDS
 - Loading TPCDS-Data
 - Benchmarks
 - Figures

## Configuration set up

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

*From now on we assume you have created a project directory on your main node(host) in which the `docker-compose.yaml` file will run and the necessary containers with their necessary configuration files will be deployed to every other node.* 
###  Installing and configuring the Presto Docker container  

 1. Download the latest non-edge Presto container from [Presto on DockerHub](https://hub.docker.com/r/prestodb/presto/tags). Run the following command:
    
    `docker pull prestodb/presto:latest`
    
    Downloading the container may take a few minutes. When the download completes, go on to the next step.
    
2.  On your repository, create a file named `./coordinator/config.properties` containing the following text:

	    coordinator=true
	    node-scheduler.include-coordinator=true
	    http-server.http.port=8080
	    query.max-memory=5GB
	    query.max-memory-per-node=1GB
	    query.max-stage-count=150
	    discovery-server.enabled=true
	    discovery.uri=http://localhost:8080
    
3.  On your repository, create a file named `./coordinator/jvm.config` containing the following text:

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
		# Change this to the number of your cpu cores of your node 
		-XX:GCLockerRetryAllocationCount=4


### Database environment
--------------------------------------------------------------------


### Connect Presto with DBs
-----------------------------------------------------------------------


## Figures 
The scripts for generating figures are located in the `./results` directory with the .txt benchmark files generated by the **presto-benchmark-driver**, while the generated figures are stored in `./plots`. 

