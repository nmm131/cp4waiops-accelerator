<center> <h1>CP4WatsonAIOps V3.2</h1> </center>
<center> <h2>Demo Environment Installation with Ansible</h2> </center>

![K8s CNI](./doc/pics/front.png)


<center> ©2021 Niklaus Hirt / IBM </center>



<div style="page-break-after: always;"></div>


# ❗ THIS IS WORK IN PROGRESS
Please drop me a note on Slack or by mail nikh@ch.ibm.com if you find glitches or problems.


# Changes

| Date  | Description  | Files  | 
|---|---|---|
|  17.09.2021 | First Draft |  |
|  20.09.2021 | Turbonomic, Humio and Tooling |  |
|  20.09.2021 | Roles |  |
|  21.09.2021 | Improved robustness and checks |  |
|  22.09.2021 | Corrected some bugs | Thanks Henning Sternkicker |
|  24.09.2021 | Corrected some bugs in the debug script | Thanks Philippe Thomas |
|  24.09.2021 | First beta release |  |
|  06.10.2021 | Resiliency and Usability |  |
|  16.10.2021 | Added EventManager (NOI) Standalone Option | |
|  20.10.2021 | Added AWX Option | Open Source Ansible Tower |
|  21.10.2021 | Added ManageIQ Option | Open Source Cloudforms |
|  26.10.2021 | 10_debug_install.sh script updated | Still work in progress |
|  27.10.2021 | New template structure |  |
|  10.11.2021 | First version for GA 3.2 |  |
|  11.11.2021 | Small tweaks  | Demo and training scripts detect AIMgr and EvtMgr Namespace automatically  |
|  11.11.2021 | Corrected missing wget  | Thanks Nate Malone |
|  18.11.2021 | Various optimizations  |  |
|  19.11.2021 | Humio install  | Based on operator |
|  23.11.2021 | Added Service Mesh/Istio  | Optional |
|  24.11.2021 | Change NOI to EventManager  |  |
|   |   |   | 


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# Installation
---------------------------------------------------------------

1. [Prerequisites](#1-prerequisites)
1. [Architecture](#2-architecture)
1. [AI Manager Base Install](#3-cp4waiops-base-install)
1. [Configure Applications and Topology](#4-configure-applications-and-topology)
1. [Training](#5-training)
1. [Slack integration](#6-slack-integration)
1. [Service Now integration](#7-service-now-integration)
1. [Some Polishing](#8-some-polishing)
1. [Demo the Solution](#9-demo-the-solution)
1. [Troubleshooting](#10-troubleshooting)
1. [Uninstall CP4WAIOPS](#11-uninstall)
1. [EventManager Install](#12-event-manager-installation)
	- [Configure EventManager](#121-configure-event-manager)
	- [Configure Runbooks](#122-configure-runbooks)
1. [Installing Turbonomic](#13-installing-turbonomic)
1. [Installing ELK (optional)](#14-installing-ocp-elk)
1. [Installing Humio (optional)](#15-humio)
1. [Installing ServiceMest/Istio (optional)](#16-servicemesh)

> ❗You can find a PDF version of this guide here: [PDF](./INSTALL_CP4WAIOPS.pdf).

<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# Introduction
---------------------------------------------------------------

This repository contains the scrips for installing a Watson AIOps demo environment with an Ansible based installer.

They have been ported over from the shell scripts here [https://github.ibm.com/NIKH/aiops-3.1](https://github.ibm.com/NIKH/aiops-3.1).

As of 3.2 and going forward I will only update the Ansible scripts in this repository.


This is provided `as-is`:

* I'm sure there are errors
* I'm sure it's not complete
* It clearly can be improved


**❗This has been tested for the new CP4WAIOPS 3.2 release on OpenShift 4.7 and 4.8.**

**I have tested on ROKS 4.7 and 4.8 and Fyre 4.6 and the scripts run to completion.**

**❗ Then EventManager/NOI-->AI Manager Gateway is not working yet on ROKS**

So please if you have any feedback contact me 

- on Slack: Niklaus Hirt or
- by Mail: nikh@ch.ibm.com


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 1. Prerequisites
---------------------------------------------------------------


## 1.1 OpenShift requirements

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.8 (4.7 should work also)
- 5x worker nodes Flavor `b3c.16x64` (so 16 CPU / 64 GB)

You might get away with less if you don't install some components (Humio, Turbonomic,...)



## 1.2 Tooling

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.7 or greater)
- jq
- kubectl (Not needed anymore - replaced by `oc`)
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)

<div style="page-break-after: always;"></div>

### 1.2.1 On Mac - Automated (preferred)
You can either run:

```
sudo ./13_install_prerequisites_mac.sh
```

#### 1.2.1.1 On Mac - Manual

Or install them manually:


```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible
brew install kafkacat
brew install node
brew install wget
npm install elasticdump -g
brew install jq

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz -o cloudctl-darwin-amd64.tar.gz
tar xfvz cloudctl-darwin-amd64.tar.gz
sudo mv cloudctl-darwin-amd64 /usr/local/bin/cloudctl
rm cloudctl-darwin-amd64.tar.gz

```


Get oc and kubectl (optional) from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-mac-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin.  (this is optional)
rm oc.tar.gz
rm README.md
```



I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Darwin_x86_64.tar.gz
tar xfzv k9s_Darwin_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```


<div style="page-break-after: always;"></div>

### 1.2.2 On Ubuntu Linux - Automated (preferred) 



For Ubuntu you can either run (for other distros you're on your own, sorry):

```
sudo ./14_install_prerequisites_ubuntu.sh
```


#### 1.2.2.1 On Ubuntu Linux - Manual

Or install them manually:


`sed` comes preinstalled

```bash
sudo apt-get install -y ansible
sudo apt-get install -y kafkacat
sudo apt-get install -y npm
sudo apt-get install -y jq
sudo npm install elasticdump -g

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz
tar xfvz cloudctl-linux-amd64.tar.gz
sudo mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
rm cloudctl-linux-amd64.tar.gz

```

Get oc and oc from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-linux-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin
rm oc.tar.gz
rm README.md
```

I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xfzv k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```

<div style="page-break-after: always;"></div>

## 1.3 Get the scripts and code from GitHub


### 1.3.1 Clone the GitHub Repository (preferred)

And obviosuly you'll need to download this repository to use the scripts.


```
git clone https://<YOUR GIT TOKEN>@github.ibm.com/NIKH/aiops-install-ansible.git 
```

You can create your GIT token [here](https://github.ibm.com/settings/tokens).

#### 1.3.1.1 Refresh the code from GitHub

Make sure you have the latest version:

```
git checkout origin/master -f | git checkout master -f | git pull origin master
```

Or create an alias for reuse:

```
alias gitrefresh='git checkout origin/master -f | git checkout master -f | git pull origin master'
```

### 1.3.2 Download the GitHub Repository in a ZIP (not preferred)

Simply click on the green `CODE` button and select `Download Zip` to download the scripts and code.

❗ If there are updates you have to re-download the ZIP.


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 2. Architecture
---------------------------------------------------------------


## 2.1 Basic Architecture

The environement (Kubernetes, Applications, ...) create logs that are being fed into a Log Management Tool (Humio in this case).

![](./doc/pics/aiops-demo.png)

1. External Systems generate Alerts and send them into the EventManager (Netcool Operations Insight), which in turn sends them to the AI Manager for Event Grouping.
1. At the same time AI Manager ingests the raw logs coming from the Log Management Tool (Humio) and looks for anomalies in the stream based on the trained model.
1. If it finds an anomaly it forwards it to the Event Grouping as well.
1. Out of this, AI Manager creates a Story that is being enriched with Topology (Localization and Blast Radius) and with Similar Incidents that might help correct the problem.
1. The Story is then sent to Slack.
1. A Runbook is available to correct the problem but not launched automatically.

<div style="page-break-after: always;"></div>

## 2.2 Optimized Demo Architecture

![](./doc/pics/aiops-demo3.png)

For the this specific Demo environment:

* Humio is not needed as I am using pre-canned logs for training and for the anomaly detection (inception)
* The Events are also created from pre-canned content that is injected into AI Manager
* There are also pre-canned ServiceNow Incidents if you don’t want to do the live integration with SNOW
* The Webpages that are reachable from the Events are static and hosted on my GitHub
* The same goes for ServiceNow Incident pages if you don’t integrate with live SNOW

This allows us to:

* Install the whole Demo Environment in a self-contained OCP Cluster
* Trigger the Anomalies reliably
* Get Events from sources that would normally not be available (Instana, Turbonomic, Metrics Manager, ...)
* Show some examples of SNOW integration without a live system


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 3. CP4WAIOPS Base Install
---------------------------------------------------------------

## 3.1 Install AI Manager

### 3.1.1 Adapt configuration

Adapt the `00_config_cp4waiops.yaml` file with the desired parameters:


#### 3.1.1.1 Automatic Login

The Playbook provides the means to automatically login to the cluster by filling out the following section of the config file:

```bash
# *************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------
# OCP LOGIN PARAMETERS
# --------------------------------------------------------------------------------------------------------------------------------------
# *************************************************************************************************************************************************
OCP_LOGIN: true
OCP_URL: https://c100-e.eu-gb.containers.cloud.ibm.com:31513
OCP_TOKEN: sha256~T6-cxxxxxxxxxxxx-dtuj3ELQfpioUhHms

#Version of your OCP Cluster (override by setting manually - 4.6, 4.7,...)
OCP_MAJOR_VERSION: automatic
```

<div style="page-break-after: always;"></div>

#### 3.1.1.2 Adapt AI Manager Config

```bash
# *************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------
# CP4WAIOPS INSTALL PARAMETERS
# --------------------------------------------------------------------------------------------------------------------------------------
# *************************************************************************************************************************************************

# CP4WAIOPS Namespace for installation
WAIOPS_NAMESPACE: cp4waiops

# CP4WAIOPS Size of the install (small: PoC/Demo, tall: Production)
WAIOPS_SIZE: small # Leave at small unless you know what you're doing

# Override the Storage Class auto detection
STORAGECLASS_FILE_OVERRIDE: not_configured
STORAGECLASS_BLOCK_OVERRIDE: not_configured
```


> There is no need to manually define the Storage Class anymore.
> The Playbook sets the storage class to `ibmc-file-gold-gid` for ROKS and `rook-cephfs` for Fyre.
> Otherwise it uses the default Storage Class.

> It is possible to override the Storage Class detection and force a custom Storage Class by setting `STORAGECLASS_XXX_OVERRIDE` in the config file.


<div style="page-break-after: always;"></div>

#### 3.1.1.3 Adapt Optional Components


```bash
# *************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------
# DEMO INSTALL PARAMETERS
# --------------------------------------------------------------------------------------------------------------------------------------
# *************************************************************************************************************************************************

# Create a demo user in the OCP cluster
CREATE_DEMO_USER: true

# Install Demo Applications
INSTALL_DEMO_APPS: true

# Print all credentials at the end of the installation
PRINT_LOGINS: true

# Install Bastion Server for Runbook Automation
INSTALL_RUNBOOK_BASTION: true

# Should Rook-Ceph be installed (automatic: install when on IBM Fyre) (enable, automatic, disable)
ROOK_CEPH_INSTALL_MODE: automatic


# *************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------
# MODULE INSTALL PARAMETERS
# --------------------------------------------------------------------------------------------------------------------------------------
# *************************************************************************************************************************************************

# Install LDAP Server
INSTALL_LDAP: true

# Install Turbonomic (experimental - needs separate license)
INSTALL_TURBONOMIC: false
# Turbonomic Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_TURBO: ibmc-block-gold
# Install Turbonomic Metrics simulation (highly experimental!)
INSTALL_TURBONOMIC_METRICS: false
# Install Turbonomic --> EventManager Gateway (highly experimental!)
INSTALL_TURBONOMIC_GATEWAY: false


# Install Humio (needs separate license)
INSTALL_HUMIO: false
# Humio Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_HUMIO: ibmc-block-gold


# Install ELK Stack
INSTALL_ELK: false

# Install AWX (Open Source Ansible Tower)
INSTALL_AWX: false

# Install ManageIQ (Open Source CloudForms)
INSTALL_MANAGEIQ: false
```

<div style="page-break-after: always;"></div>

### 3.1.2 Get the installation token

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

This token is being referred to as <PULL_SECRET_TOKEN> below and should look something like this (this is NOT a valid token):

```yaml
eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY  
```

<div style="page-break-after: always;"></div>

### 3.1.3 🚀 Start installation

Just run:

```bash
./10_install_ai_manager.sh -t <PULL_SECRET_TOKEN> [-v true]


Example:
./10_install_ai_manager.sh -t eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:


- CP4WAIOPS AI Manager
- OpenLDAP (if enabled)
- Demo Apps (if enabled)
- Register LDAP Users (if enabled)
- Housekeeping
	- Additional Routes (Topology, Flink)
	- Create OCP User (serviceaccount demo-admin)
	- Patch Ingress
	- Adapt NGINX Certificates
	- Adapt Slack Welcome message to /welcome
- Turbonomic (if enabled)
- Humio (if enabled)
- OCP ELK Stack (if enabled)
- AWX (Open Source Ansible Tower - if enabled)
- ManageIQ (Open Source CloudForms - if enabled)

<div style="page-break-after: always;"></div>

## 3.2 Install EventManager

To get the token, see [here](#3.1.2-get-the-installation-token) 

### 3.2.1 🚀 Start installation

Just run:

```bash
./11_install_event_manager.sh -t <PULL_SECRET_TOKEN> [-v true]


Example:
./11_install_event_manager.sh -t eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:

- CP4WAIOPS EventManager
- Gateway





<div style="page-break-after: always;"></div>


## 3.3 Get Passwords and Credentials

At any moment you can run `./tools/20_get_logins.sh` that will print out all the relevant passwords and credentials.

Usually it's a good idea to store this in a file for later use:

```bash
./tools/20_get_logins.sh > my_credentials.txt
```

## 3.4 Check status of installation

At any moment you can run `./tools/11_check_install.sh` or for a more in-depth examination and troubleshooting `./tools/10_debug_install.sh` and select `Option 1` to check your installation.


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 4. Configure Applications and Topology
---------------------------------------------------------------



## 4.1 Create Kubernetes Observer for the Demo Applications

Do this for your applications (RobotShop by default)

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kubernetes`, click on `Add Integration`
* Click `Connect`
* Name it `RobotShop`
* Data Center `demo`
* Click `Next`
* Choose `local` for Connection Type
* Set `Hide pods that have been terminated` to `On`
* Set `Correlate analytics events on the namespace groups created by this job` to `On`
* Set Namespace to `robot-shop`
* Click `Next`
* Click `Done`




## 4.2 Create REST Observer to Load Topologies

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* On the left click on `Topology`
* On the top right click on `You can also configure, schedule, and manage other observer jobs` 
* Click on  `Add a new Job`
* Select `REST`/ `Configure`
* Choose “bulk_replace”
* Set Unique ID to “listenJob” (important!)
* Set Provider to whatever you like (usually I set it to “listenJob” as well)
* `Save`







<div style="page-break-after: always;"></div>

## 4.3 Create Merge Rules for Kubernetes Observer

Launch the following:

```bash
./60_load_robotshop_topology_aimanager.sh
```

This will create:

- Merge Rules
- Merge Topologies for RobotShop.

❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.


## 4.5 Create AIOps Application

#### Robotshop

* In the `AI Manager` go into `Operate` / `Application Management` 
* Click `Create Application`
* Select `robot-shop` namespace
* Click `Add to Application`
* Name your Application (RobotShop)
* If you like check `Mark as favorite`
* Click `Save`



<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 5. Training
---------------------------------------------------------------

## 5.1 Prepare Training

### 5.1.1 Create Kafka Humio Log Training Integration

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `HumioInject`
* Click `Next`
* Select `Data Source` / `Logs`
* Select `Mapping Type` / `Humio`
* Paste the following in `Mapping` (the default is **incorrect**!:

	```json
	{
	"codec": "humio",
	"message_field": "@rawstring",
	"log_entity_types": "kubernetes.namespace_name,kubernetes.container_hash,kubernetes.host,kubernetes.container_name,kubernetes.pod_name",
	"instance_id_field": "kubernetes.container_name",
	"rolling_time": 10,
	"timestamp_field": "@timestamp"
	}
	```
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Select `Live data for continuous AI training and anomaly detection`
* Click `Save`


<div style="page-break-after: always;"></div>

### 5.1.2 Create Kafka Netcool Training Integration

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `EvetnManager`
* Click `Next`
* Select `Data Source` / `Events`
* Select `Mapping Type` / `NOI`
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Click `Save`



### 5.1.3 Create ElasticSearch Port Forward

Please start port forward in **separate** terminal.

Run the following:

```bash
while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done
```
or use the script that does it automatically

```bash
./tools/28_access_elastic.sh
```

<div style="page-break-after: always;"></div>

## 5.2 Load Training Data

Run the following scripts to inject training data:
	
```bash
./50_load_robotshop_data.sh	
```

This takes some time (20-60 minutes depending on your Internet speed).

<div style="page-break-after: always;"></div>

## 5.3 Train Log Anomaly

### 5.3.1 Create Training Definition for Log Anomaly

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Log anomaly detection - natural language`  click on `Configure`
* Click `Next`
* Name it `LogAnomaly`
* Click `Next`
* Select `Custom`
* Select `05/05/21` (May 5th 2021 - dd/mm/yy) to `07/05/21` (May 7th 2021) as date range (this is when the logs we're going to inject have been created)
* Click `Next`
* Click `Next`
* Click `Create`


### 5.3.2 Train the Log Anomaly model

* Click on the `Manager` Tab
* Click on the `LogAnomaly` entry
* Click `Start Training`
* This will start a precheck that should tell you after a while that you are ready for training ant then start the training

After successful training you should get: 

![](./doc/pics/training1.png)

* Click on `Deploy vXYZ`


⚠️ If the training shows errors, please make sure that the date range of the training data is set to May 5th 2021 through May 7th 2021 (this is when the logs we're going to inject have been created)


<div style="page-break-after: always;"></div>

## 5.4 Train Event Grouping

### 5.4.1 Create Training Definition for Event Grouping

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Temporal grouping` click on `Configure`
* Click `Next`
* Name it `EventGrouping`
* Click `Next`
* Click `Done`


### 5.4.2 Train the Event Grouping Model


* Click on the `Manager` Tab
* Click on the `EventGrouping ` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training2.png)

* The model is deployed automatically






<div style="page-break-after: always;"></div>

## 5.5 Train Incident Similarity

#### ❗ Only needed if you don't plan on doing the Service Now Integration


### 5.5.1 Create Training Definition

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Similar incidents` click on `Configure`
* Click `Next`
* Name it `SimilarIncidents`
* Click `Next`
* Click `Next`
* Click `Done`


### 5.5.2 Train the Incident Similarity Model


* Click on the `Manager` Tab
* Click on the `SimilarIncidents` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training3.png)

* The model is deployed automatically




<div style="page-break-after: always;"></div>

## 5.6 Train Change Risk

#### ❗ Only needed if you don't plan on doing the Service Now Integration


### 5.6.1 Create Training Definition

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Change risk` click on `Configure`
* Click `Next`
* Name it `ChangeRisk`
* Click `Next`
* Click `Next`
* Click `Done`


### 5.6.2 Train the Change Risk Model


* Click on the `Manager` Tab
* Click on the `ChangeRisk ` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training4.png)

* Click on `Deploy vXYZ`











<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 6. Slack integration
---------------------------------------------------------------

## 6.1 Initial Slack Setup 

For the system to work you need to setup your own secure gateway and slack workspace. It is suggested that you do this within the public slack so that you can invite the customer to the experience as well. It also makes it easier for is to release this image to Business partners

You will need to create your own workspace to connect to your instance of CP4WAOps.

Here are the steps to follow:

1. [Create Slack Workspace](./doc/slack/1_slack_workspace.md)
1. [Create Slack App](./doc/slack/2_slack_app_create.md)
1. [Create Slack Channels](./doc/slack/3_slack_channel.md)
1. [Create Slack Integration](./doc/slack/4_slack_integrate.md)
1. [Get the Integration URL - Public Cloud - ROKS](./doc/slack/5_slack_url_public.md) OR 
1. [Get the Integration URL - Private Cloud - Fyre/TEC](./doc/slack/5_slack_url_private.md)
1. [Create Slack App Communications](./doc/slack/6_slack_app_integration.md)
1. [Prepare Slack Reset](./doc/slack/7_slack_reset.md)



## 6.2 NGNIX Certificate for V3.1.1 - If the integration is not working


In order for Slack integration to work, there must be a signed certicate on the NGNIX pods. The default certificate is self-signed and Slack will not accept that. The method for updating the certificate has changed between AIOps v2.1 and V3.1.1. The NGNIX pods in V3.1.1 mount the certificate through a secret called `external-tls-secret` and that takes precedent over the certificates staged under `/user-home/_global_/customer-certs/`.

For customer deployments, it is required for the customer to provide their own signed certificates. An easy workaround for this is to use the Openshift certificate when deploying on ROKS. **Caveat**: The CA signed certificate used by Openshift is automatically cycled by ROKS (I think every 90 days), so you will need to repeat the below once the existing certificate is expired and possibly reconfigure Slack.



This method replaces the existing secret/certificate with the one that OpenShift ingress uses, not altering the NGINX deployment. An important note, these instructions are for configuring the certificate post-install. Best practice is to follow the installation instructions for configuring certificates during that time.

The custom resource `AutomationUIConfig/iaf-system` controls the certificates and the NGINX pods that use those certificates. Any direct update to the certificates or pods will eventually get overwritten, unless you first reconfigure `iaf-system`. It's a bit tricky post-install as you will have to recreate the `iaf-system` resource quickly after deleting it, or else the installation operator will recreate it. For this reason it's important to run all the commands one after the other. **Ensure that you are in the project for AIOps**, then paste all the code on your command line to replace the `iaf-system` resource.

```bash
NAMESPACE=$(oc project -q)
IAF_STORAGE=$(oc get AutomationUIConfig -n $NAMESPACE -o jsonpath='{ .items[*].spec.storage.class }')
oc get -n $NAMESPACE AutomationUIConfig iaf-system -oyaml > iaf-system-backup.yaml
oc delete -n $NAMESPACE AutomationUIConfig iaf-system
cat <<EOF | oc apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: iaf-system
  namespace: $NAMESPACE
spec:
  description: AutomationUIConfig for cp4waiops
  license:
    accept: true
  version: v1.0
  storage:
    class: $IAF_STORAGE
  tls:
    caSecret:
      key: ca.crt
      secretName: external-tls-secret
    certificateSecret:
      secretName: external-tls-secret
EOF
```

<div style="page-break-after: always;"></div>


Again, **ensure that you are in the project for AIOps** and run the following to replace the existing secret with a secret containing the OpenShift ingress certificate.

```bash
WAIOPS_NAMESPACE =$(oc project -q)
# collect certificate from OpenShift ingress
ingress_pod=$(oc get secrets -n openshift-ingress | grep tls | grep -v router-metrics-certs-default | awk '{print $1}')
oc get secret -n openshift-ingress -o 'go-template={{index .data "tls.crt"}}' ${ingress_pod} | base64 -d > cert.crt
oc get secret -n openshift-ingress -o 'go-template={{index .data "tls.key"}}' ${ingress_pod} | base64 -d > cert.key
oc get secret -n $WAIOPS_NAMESPACE iaf-system-automationui-aui-zen-ca -o 'go-template={{index .data "ca.crt"}}'| base64 -d > ca.crt
# backup existing secret
oc get secret -n $WAIOPS_NAMESPACE external-tls-secret -o yaml > external-tls-secret$(date +%Y-%m-%dT%H:%M:%S).yaml
# delete existing secret
oc delete secret -n $WAIOPS_NAMESPACE external-tls-secret
# create new secret
oc create secret generic -n $WAIOPS_NAMESPACE external-tls-secret --from-file=ca.crt=ca.crt --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | oc apply -f -
#oc create secret generic -n $WAIOPS_NAMESPACE external-tls-secret --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | oc apply -f -
# scale down nginx
REPLICAS=2
oc scale Deployment/ibm-nginx --replicas=0
# scale up nginx
sleep 3
oc scale Deployment/ibm-nginx --replicas=${REPLICAS}
rm external-tls-secret
```


Wait for the nginx pods to come back up

```bash
oc get pods -l component=ibm-nginx
```

When the integration is running, remove the backup file

```bash
rm ./iaf-system-backup.yaml
```

And then restart the Slack integration Pod

```bash
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep slack|awk '{print$1}') -n $WAIOPS_NAMESPACE --grace-period 0 --force
```

The last few lines scales down the NGINX pods and scales them back up. It takes about 3 minutes for the pods to fully come back up.

Once those pods have come back up, you can verify the certificate is secure by logging in to AIOps. Note that the login page is not part of AIOps, but rather part of Foundational Services. So you will have to login first and then check that the certificate is valid once logged in. If you want to update the certicate for Foundational Services you can find instructions [here](https://www.ibm.com/docs/en/cpfs?topic=operator-replacing-foundational-services-endpoint-certificates).



## 6.3 Change the Slack Slash Welcome Message (optional)

If you want to change the welcome message

```bash
oc set env deployment/$(oc get deploy -l app.kubernetes.io/component=chatops-slack-integrator -o jsonpath='{.items[*].metadata.name }') SLACK_WELCOME_COMMAND_NAME=/aiops-help
```


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 7. Service Now integration
---------------------------------------------------------------



## 7.1 Integration 

1. Follow [this](./doc/servicenow/snow-Integrate.md) document to get and configure your Service Now Dev instance with CP4WAIOPS.
	Stop at `Testing the ServiceNow Integration`. 
	❗❗Don’t do the training as of yet.
2. Import the Changes from ./doc/servicenow/import_change.xlsx
	1. Select `Change - All` from the right-hand menu
	2. Right Click on `Number`in the header column
	3. Select Import
	![](./doc/pics/snow3.png)
	3. Chose the ./doc/servicenow/import_change.xlsx file and click `Upload`
	![](./doc/pics/snow4.png)
	3. Click on `Preview Imported Data`
	![](./doc/pics/snow5.png)
	3. Click on `Complete Import` (if there are errors or warnings just ignore them and import anyway)
	![](./doc/pics/snow6.png)
	
3. Import the Incidents from ./doc/servicenow/import_incidents.xlsx
	1. Select `Incidents - All` from the right-hand menu
	2. Proceed as for the Changes but for Incidents
	
4. Now you can finish configuring your Service Now Dev instance with CP4WAIOPS by [going back](./doc/servicenow/snow-Integrate.md#testing-the-servicenow-integration) and continue whre you left off at `Testing the ServiceNow Integration`. 




<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 8. Some Polishing
---------------------------------------------------------------

## 8.1 Add LDAP Logins to CP4WAIOPS


* Go to `AI Manager` Dashboard
* Click on the top left "Hamburger" menu
* Select `User Management`
* Select `User Groups` Tab
* Click `New User Group`
* Enter demo (or whatever you like)
* Click Next
* Select `LDAP Groups`
* Search for `demo`
* Select `cn=demo,ou=Groups,dc=ibm,dc=com`
* Click Next
* Select Roles (I use Administrator for the demo environment)
* Click Next
* Click Create



## 8.2 Monitor Kafka Topics

At any moment you can run `./tools/22_monitor_kafka.sh` this allows you to:

* List all Kafka Topics
* Monitor Derived Stories
* Monitor any specific Topic

<div style="page-break-after: always;"></div>

## 8.3 Monitor ElasticSearch Indexes

At any moment you can run `./tools/28_access_elastic.sh` in a separate terminal window.

This allows you to access ElasticSearch and gives you:

* ES User
* ES Password

	![](./doc/pics/es0.png)
	

### 8.3.1 Monitor ElasticSearch Indexes from Firefox

I use the [Elasticvue](https://addons.mozilla.org/en-US/firefox/addon/elasticvue/) Firefox plugin.

Follow these steps to connects from Elasticvue:

- Select `Add Cluster` 
	![](./doc/pics/es1.png)

<div style="page-break-after: always;"></div>

- Put in the credentials and make sure you put `https` and not `http` in the URL
	![](./doc/pics/es2.png)
- Click `Test Connection` - you will get an error
- Click on the `https://localhost:9200` URL
	![](./doc/pics/es3.png)
	
<div style="page-break-after: always;"></div>

- This will open a new Tab, select `Accept Risk and Continue` 
	![](./doc/pics/es4.png)
- Cancel the login screen and go back to the previous tab
- Click `Connect` 
- You should now be connected to your AI Manager ElasticSearch instance 
	![](./doc/pics/es5.png)

---


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 9. Demo the Solution
---------------------------------------------------------------



## 9.1 Simulate incident

**Make sure you are logged-in to the Kubernetes Cluster first** 

In the terminal type 

```bash
./tools/01_demo/incident_robotshop.sh
```

This will delete all existing Alerts and inject pre-canned event and logs to create a story.

ℹ️  Give it a minute or two for all events and anomalies to arrive in Slack.




<div style="page-break-after: always;"></div>

---------------------------------------------------------------

# 10. TROUBLESHOOTING
---------------------------------------------------------------

## 10.1 Check with script

❗ There is a new script that can help you automate some common problems in your CP4WAIOPS installation.

Just run:

```
./tools/10_debug_install.sh
```

and select `Option 1`


## 10.2 Pods in Crashloop

If the evtmanager-topology-merge and/or evtmanager-ibm-hdm-analytics-dev-inferenceservice are crashlooping, apply the following patches. I have only seen this happen on ROKS.

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch deployment evtmanager-topology-merge -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/pazch/topology-merge-patch.yaml


oc patch deployment evtmanager-ibm-hdm-analytics-dev-inferenceservice -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/patch/evtmanager-inferenceservice-patch.yaml
```


<div style="page-break-after: always;"></div>

## 10.3 Pods with Pull Error

If the ir-analytics or cassandra job pods are having pull errors, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-topology-service-account -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-worker -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-pipeline-composer -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-master -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-probablecause -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-classifier -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-lifecycle-eventprocessor-ep -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep ImagePull|awk '{print$1}') -n $WAIOPS_NAMESPACE


```


## 10.4 Camel-K Handlers Error

If the scm-handler or snow-handler pods are not coming up, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch vaultaccess/ibm-vault-access -p '{"spec":{"token_period":"760h"}}' --type=merge -n $WAIOPS_NAMESPACE
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep 0/|awk '{print$1}') -n $WAIOPS_NAMESPACE

```




## 10.5 Slack integration not working

See [here](#ngnix-certificate-for-v31---if-the-integration-is-not-working)

<div style="page-break-after: always;"></div>

## 10.6 Check if data is flowing



### 10.6.1 Check Log injection

To check if logs are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 4

You should see data coming in.

### 10.6.2 Check Events injection

To check if events are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 3

You should see data coming in.

### 10.6.3 Check Stories being generated

To check if stories are being generated:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 2

You should see data being generated.

<div style="page-break-after: always;"></div>

## 10.7 Docker Pull secret

####  ❗⚠️ Make a copy of the secret before modifying 
####  ❗⚠️ On ROKS (any version) and before 4.7 you have to restart the worker nodes after the modification  

We learnt this the hard way...

```bash
oc get secret -n openshift-config pull-secret -oyaml > pull-secret_backup.yaml
```

or more elegant

```bash
oc get Secret -n openshift-config pull-secret -ojson | jq 'del(.metadata.annotations, .metadata.creationTimestamp, .metadata.generation, .metadata.managedFields, .metadata.resourceVersion , .metadata.selfLink , .metadata.uid, .status)' > pull-secret_backup.json
```

In order to avoid errors with Docker Registry pull rate limits, you should add your Docker credentials to the Cluster.
This can occur especially with Rook/Ceph installation.

* Go to Secrets in Namespace `openshift-config`
* Open the `pull-secret`Secret
* Select `Actions`/`Edit Secret` 
* Scroll down and click `Add Credentials`
* Enter your Docker credentials

	![](./doc/pics/dockerpull.png)

* Click Save

If you already have Pods in ImagePullBackoff state then just delete them. They will recreate and should pull the image correctly.

<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 11. Uninstall
---------------------------------------------------------------

❗ The scritps are coming from here [https://github.com/IBM/cp4waiops-samples.git](https://github.com/IBM/cp4waiops-samples.git)

If you run into problems check back if there have been some updates.


I have tested those on 3.1.1 as well and it seemed to work (was able to do a complete reinstall afterwards).

Just run:

```
./tools/99_uninstall/3.2/uninstall-cp4waiops.props
```





<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 12. EventManager Installation
---------------------------------------------------------------

## 12.1. Configure EventManager

❗ You only have to do this if you have installed EventManager/NOI (As described in Chapter 3.2). For basic demoing with AI MAnager this is not needed.

### 12.1.1 EventManager Webhooks

Create Webhooks in EventManager for Event injection and incident simulation for the Demo.

The demo scripts (in the `demo` folder) give you the possibility to simulate an outage without relying on the integrations with other systems.

At this time it simulates:

- Git push event
- Log Events (Humio)
- Security Events (Falco)
- Instana Events
- Metric Manager Events (Predictive)
- Turbonomic Events
- CP4MCM Synthetic Selenium Test Events




#### 12.1.1.1 Generic Demo Webhook

You have to define the following Webhook in EventManager (NOI): 

* `Administration` / `Integration with other Systems`
* `Incoming` / `New Integration`
* `Webhook`
* Name it `Demo Generic`
* Jot down the WebHook URL and copy it to the `NETCOOL_WEBHOOK_GENERIC` in the `00_config-secrets.sh`file
* Click on `Optional event attributes`
* Scroll down and click on the + sign for `URL`
* Click `Confirm Selections`


<div style="page-break-after: always;"></div>
Use this json:

```json
{
  "timestamp": "1619706828000",
  "severity": "Critical",
  "summary": "Test Event",
  "nodename": "productpage-v1",
  "alertgroup": "robotshop",
  "url": "https://pirsoscom.github.io/grafana-robotshop.html"
}
```

Fill out the following fields and save:

* Severity: `severity`
* Summary: `summary`
* Resource name: `nodename`
* Event type: `alertgroup`
* Url: `url`
* Description: `"URL"`

Optionnally you can also add `Expiry Time` from `Optional event attributes` and set it to a convenient number of seconds (just make sure that you have time to run the demo before they expire.


### 12.1.2 Create custom Filter and View in EventManager/ (optional)

#### 12.1.2.1 Filter

Duplicate the `Default` filter and set to global.

* Name: AIOPS
* Logic: **Any** (!)
* Filter:
	* AlertGroup = 'CEACorrelationKeyParent'
	* AlertGroup = 'robot-shop'

#### 12.1.2.2 View

Duplicate the `Example_IBM_CloudAnalytics` View and set to global.


* Name: AIOPS

Configure to your likings.

<div style="page-break-after: always;"></div>

### 12.1.3 Create Templates for Topology Grouping (optional)

This gives you probale cause and is not strictly needed if you don't show EventManager!

* In the EventManager "Hamburger" Menu select `Operate`/`Topology Viewer`
* Then, in the top right corner, click on the icon with the three squares (just right of the cog)
* Select `Create a new Template`
* Select `Dynamic Template`

Create a template for RobotShop:

* Search for `web-deployment` (deployment)
* Create Topology 3 Levels
* Name the template (robotshop)
* Select `Namespace` in `Group type`
* Enter `robotshop_` for `Name prefix`
* Select `Application` 
* Add tag `namespace:robot-shop`
* Save




### 12.1.4 Create grouping Policy

* NetCool Web Gui --> `Insights` / `Scope Based Grouping`
* Click `Create Policy`
* `Action` select fielt `Alert Group`
* Toggle `Enabled` to `On`
* Save

<div style="page-break-after: always;"></div>

### 12.1.5 Create EventManager/NOI Menu item - Open URL

in the Netcool WebGUI

* Go to `Administration` / `Tool Configuration`
* Click on `LaunchRunbook`
* Copy it (the middle button with the two sheets)
* Name it `Launch URL`
* Replace the Script Command with the following code

	```javascript
	var urlId = '{$selected_rows.URL}';
	
	if (urlId == '') {
	    alert('This event is not linked to an URL');
	} else {
	    var wnd = window.open(urlId, '_blank');
	}
	```
* Save

Then 

* Go to `Administration` / `Menu Configuration`
* Select `alerts`
* Click on `Modify`
* Move Launch URL to the right column
* Save



<div style="page-break-after: always;"></div>



## 12.2 Configure Runbooks



### 12.2.1 Create Bastion Server

A simple Pod with the needed tools (oc, kubectl) being used as a bastion host for Runbook Automation should already have been created by the install script. 



### 12.2.2 Create the EventManager/NOI Integration

#### 12.2.2.1 In EventManager/NOI

* Go to  `Administration` / `Integration with other Systems` / `Automation Type` / `Script`
* Copy the SSH KEY


#### 12.2.2.2 Adapt SSL Certificate in Bastion Host Deployment. 

* Select the `bastion-host` Deployment in Namespace `default`
* Adapt Environment Variable SSH_KEY with the key you have copied above.



### 12.2.3 Create Automation


#### 12.2.3.1 Connect to Cluster
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc login --token=$token --server=$ocp_url
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root
$token	 : Token from your login (from ./tools/20_get_logins.sh)	
$ocp_url : URL from your login (from ./tools/20_get_logins.sh, something like https://c102-e.eu-de.containers.cloud.ibm.com:32236)		
```

<div style="page-break-after: always;"></div>

#### 12.2.3.2 RobotShop Mitigate MySql
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc scale deployment --replicas=1 -n robot-shop ratings
oc delete pod -n robot-shop $(oc get po -n robot-shop|grep ratings |awk '{print$1}') --force --grace-period=0
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root		
```


### 12.2.4 Create Runbooks


* `Library` / `New Runbook`
* Name it `Mitigate RobotShop Problem`
* `Add Automated Step`
* Add `Connect to Cluster`
* Select `Use default value` for all parameters
* Then `RobotShop Mitigate Ratings`
* Select `Use default value` for all parameters
* Click `Publish`




### 12.2.5 Add Runbook Triggers

* `Triggers` / `New Trigger`
* Name and Description: `Mitigate RobotShop Problem`
* Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-instana or mysql-predictive
* Click `Run Test`
* You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
* Select `Mitigate RobotShop Problem`
* Click `Select This Runbook`
* Toggle `Execution` / `Automatic` to `off`
* Click `Save`



<div style="page-break-after: always;"></div>

-----------------------------------------------------------------------------------
# 13. Installing Turbonomic
---------------------------------------------------------------

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

## 13.1 Installing Turbonomic

You can install Turbonomic into the same cluster as CP4WAIOPS.

**❗ You need a license in order to use Turbonomic.**

1. Launch

	```bash
	ansible-playbook ./ansible/20_install-turbonomic.yaml
	```
2. Wait for the pods to come up
3. Open Turbonomic
4. Enter the license
5. Add the default target (local Kubernetes cluster is already instrumented with `kubeturbo`)

It can take several hours for the Supply Chain to populate, so be patient.

## 13.2 Installing kubeturbo

In order to get other Kubernetes clusters to show up in Turbonomic, you have to install `kubeturbo` (your main cluster is already registered).

1. Adapt `./ansible/templates/kubeturbo/my_kubeturbo_instance_cr.yaml` with the Turbonomic URL and the login
2. Launch

	```bash
	ansible-playbook ./ansible/20_1_aiops-addons-kubeturbo.yaml
	```
<div style="page-break-after: always;"></div>

## 13.3 Turbo to WAIOPS Gateway

**❗This is not an officialy supported tool by any means and is still under heavy development!**

In order to push Turbonomic Actions into EventManager you can use my tool.
This tool needs existing `Business Applications`, you can either integrate with Instana (or other APMs) or create one under Settings/Topology.

1. Adapt the `./ansible/templates/turbo-gateway/create-turbo-gateway.yaml` file 

	| Variable | Default Value | Description |
	| -------- | ------------- | ----------- |
	|POLLING_INTERVAL| '300' | Poll every X seconds |
	|EVTMGR_SUMMARY_PREFIX| '[Turbonomic] ' | Prefix in the event summary |
	|EVTMGR_WEBHOOK_URL| netcool-evtmanager.apps.clustername.domain | EventManager hostname |
	|EVTMGR_WEBHOOK_PATH| /norml/xxxx | Webhook URL from EventManager (does not inclue the hostname, only `/norml/xxxx`) |
	|TURBO_API_URL| api-turbonomic.apps.clustername.domain | Turbonomic API URL |
	|TURBO_BA_NAME| 'RobotShop:robot-shop'| Turbonomic application name in the format APPNAME:ALERTGROUP. This links an EventManager alertgroup with an application |
	|ACTION_STATES| 'SUCCEEDED,FAILED,READY,IN_PROGRESS' | The list of ACTION_STATES to filter on |
	|ACTION_TYPES| 'MOVE,RESIZE_FOR_PERFORMANCE,RESIZE_FOR_EFFICIENCY,RESIZE' | The list of ACTION_TYPES to filter on |
	|DEBUG_ENABLED| 'false' | Enable additional log output |
	|ENTITY_TYPES| 'VirtualMachine,Application,PhysicalMachine,ContainerSpec,WorkloadController,Container' | The list of ENTITY_TYPES to filter on |
	|ACTION_START_TIME| '-30m'| Period of time in which actions are retrieved. E.g. -5m, -30m, -1h, -1d, -3d, -7d | 

2. Create Turbonomic Credentials Secret

	You can either:
	
	- create the secret from the command line (which will throw a warning for the already existing Secret when installing)
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=<youruser> --from-literal=TURBO_PWD=<yourpw>
		```
	
	
	- replace the secret in the yaml file with
	
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=apiuser --from-literal=TURBO_PWD=turboadmin -o yaml --dry-run=client
		```
	
3. Create Generic Webhook in EventManager/NOI with:

	```json
	{
	"timestamp": "1619706828000",
	"severity": "Critical",
	"summary": "Test Event",
	"nodename": "productpage-v1",
	"alertgroup": "robotshop",
	"url": "https://myturbo/something.html"
	}
	```
4. Launch 

	```shell
	ansible-playbook ./ansible/20_3_aiops-addons-turbonomic-gateway.yaml
	```

<div style="page-break-after: always;"></div>

## 13.4 Generate Metrics

**❗This is not an officialy supported tool by any means and is still under heavy development!**

If you have manually created a `Business Applications` you won't get any ResponseTime and Transactions metrics.
With this tool you can you can add randomized ResponseTime and Transactions metrics to the `Business Application` through the `Data Integration Framework (DIF)`.

> Note: The metrics pod can also serve metrics for other `Entity` types (businessApplication, businessTransaction, service, databaseServer, application)
> 
> Note: There is also a Route being created by the installer, so that you can test the URLs.
> 

1. Launch

	```shell
	ansible-playbook ./ansible/20_2_aiops-addons-turbonomic-metrics.yaml
	```

1. Wait for the Pod to become available
1. Add the DIF Target
	2. Go to `Settings/Target Configurations`
	2. Click `New Target`
	2. Select `Custom/DataIngestionFramework`
	2. Put in the URL for the metrics (see below) and a name
	2. Click `Add`
	3. Make sure that Target is green and reads `Validated`

It takes some time for the metrics to start showing up. Polling is every 10 minutes 

### 13.4.1 Test URL

You can use the following URL to test if everything is working:

`http://turbo-dif-service.default:3000/helloworld`

This will create a standalone `Business Application` called `Hello World` without any other `Entities` attached to it. 
But with metrics being ingested.

### 13.4.2 Construct the URL

The URL has the format of:

```yaml
http://turbo-dif-service.default:3000/<TYPE>/<NAME>/<UUID>
```

where:

- TYPE: Type of the `Entity` (businessApplication/businessTransaction/service/databaseServer/application)
- NAME: The name of the `Entity`
- UUID: The UUID that you can find under `Entity Information / Show All / Vendor ID`

So an example might be:
`http://turbo-dif-service.default:3000/service/Service-robot-shop%2Fcatalogue/b2d6fd52-c895-469e-bb98-2a791faefce7`
`http://turbo-dif-service.default:3000/businessApplication/RobotShop/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopCatalog/285333292080720`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShoßpPayment/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopUser/285333133684640`


<div style="page-break-after: always;"></div>

-----------------------------------------------------------------------------------
# 14. Installing OCP ELK
---------------------------------------------------------------

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

You can easily install ELK into the same cluster as CP4WAIOPS.


1. Launch

	```bash
	ansible-playbook ./ansible/22_install-elk-ocp.yaml
	```
2. Wait for the pods to come up
3. Open Kibana


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 15. HUMIO 
---------------------------------------------------------------

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

> ❗This demo supports pre-canned events and logs, so you don't need to install and configure Humio unless you want to do a live integration (only partially covered in this document).

## 15.1 Create Licence Secret

Before starting the installation you have to create the Secret with the licence information.

```bash
oc create ns humio-logging
oc create secret generic humio-license -n humio-logging --from-literal=data=eyJhbGciOiJFUzxxxxaWmdRTrr_ksdfaa
```

## 15.2 Install Humio and Fluentbit

Just launch the following and this should automatically install:

* Kafka
* Zookeeper
* Humio Core
* Humio Repository
* Humio Ingest Token
* Fluentbit


```bash
ansible-playbook ./ansible/21_install-humio.yaml
```



## 15.3 Live Humio integration with AIManager

### 15.3.1 Humio URL

- Get the Humio Base URL from your browser
- Add at the end `/api/v1/repositories/aiops/query`


### 15.3.2 Accounts Token

Get it from Humio --> `Owl` in the top right corner / `Your Account` / `API Token
`
### 15.3.3 Create Humio Log Integration

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Humio`, click on `Add Connection`
* Click `Connect`
* Name it `Humio`
* Paste the URL from above (`Humio service URL`)
* Paste the Token from above (`API key`)
* In `Filters (optional)` put the following:

	```yaml
	"kubernetes.namespace_name" = /robot-shop/
	| "kubernetes.container_name" != load
	```
* Click `Next`
* Put in the following mapping:

	```yaml
	{
	  "codec": "humio",
	  "message_field": "@rawstring",
	  "log_entity_types": "clusterName, kubernetes.container_image_id, kubernetes.host, kubernetes.container_name, kubernetes.pod_name",
	  "instance_id_field": "kubernetes.container_name",
	  "rolling_time": 10,
	  "timestamp_field": "@timestamp"
	}
	```

* Click `Test Connection`
* Switch `Data Flow` to the `ON` position ❗
* Select the option for your use case:
	* `Live data for continuous AI training and anomaly detection` if you want to enable log anomaly detection
	* `Live data for initial AI training` if you want to start ingesting live data for later training
	* `Historical data for initial AI training` if you want to ingest historical data to start training rapidly
* Click `Done`

### 15.3.4 Create Humio Events Integration

Events integration is done via EventManager/NOI.

For the time being this only takes the first alert being pushed over (no way to handle arrays).
The native Humio integration seems to have a bug that gives "mergeAdvanced is not a function".


#### 15.3.4.1 On the EventManager/NOI side

Create a Webhook integration:

| Field  | Value  | 
|---|---|
| Severity|"Critical"|
| Summary|  alert.name|
| Resource name | events[0]."kubernetes.container_name"|
| Event type |   events[0]."kubernetes.namespace_name"|



With this sample payload:

```json
{
  "repository": "aiops",
  "timestamp": "2021-11-19T15:50:04.958Z",
  "alert": {
    "name": "test1",
    "description": "",
    "query": {
      "queryString": "\"kubernetes.container_name\" = ratings\n| @rawstring = /error/i ",
      "end": "now",
      "start": "2s"
    },
    "notifierID": "Rq4a9KUbomSIBvEcdC7kzzmdBtPI3yPb",
    "id": "rCA2w5zaIE6Xr3RKlFfhAxqqbGqGxGLC"
  },
  "warnings": "",
  "events": [
    {
      "kubernetes.annotations.openshift_io/scc": "anyuid",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/network-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.annotations.cni_projectcalico_org/podIPs": "172.30.30.153/32",
      "@timestamp.nanos": "0",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/networks-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.pod_name": "ratings-5d9dff56bd-864kq",
      "kubernetes.labels.service": "ratings",
      "kubernetes.annotations.cni_projectcalico_org/podIP": "172.30.30.153/32",
      "kubernetes.host": "10.112.243.226",
      "kubernetes.container_name": "ratings",
      "kubernetes.labels.pod-template-hash": "5d9dff56bd",
      "kubernetes.docker_id": "87a98617a14684c02d9d52a6245af377f8b1a246d196f232cad494a7a2d125b7",
      "@ingesttimestamp": "1637337004272",
      "kubernetes.container_hash": "docker.io/robotshop/rs-ratings@sha256:4899c686c249464783663342620425dc8c75a5d59ca55c247cf6aec62a5fff1a",
      "kubernetes.container_image": "docker.io/robotshop/rs-ratings:latest",
      "#repo": "aiops",
      "@timestamp": 1637337003872,
      "kubernetes.namespace_name": "robot-shop",
      "@timezone": "Z",
      "@rawstring": "2021-11-19T09:50:03.872288692-06:00 stdout F [2021-11-19 15:50:03] php.INFO: User Deprecated: Since symfony/http-kernel 5.3: \"Symfony\\Component\\HttpKernel\\Event\\KernelEvent::isMasterRequest()\" is deprecated, use \"isMainRequest()\" instead. {\"exception\":\"[object] (ErrorException(code: 0): User Deprecated: Since symfony/http-kernel 5.3: \\\"Symfony\\\\Component\\\\HttpKernel\\\\Event\\\\KernelEvent::isMasterRequest()\\\" is deprecated, use \\\"isMainRequest()\\\" instead. at /var/www/html/vendor/symfony/http-kernel/Event/KernelEvent.php:88)\"} []",
      "@id": "tiMU0F8kdNf6x0qMduS9T31q_269_400_1637337003",
      "kubernetes.pod_id": "09d64ec8-c09f-4650-871f-adde27ca863e",
      "#type": "unparsed",
      "kubernetes.annotations.cni_projectcalico_org/containerID": "337bf300371c84500756a6e94e58b2d8ee54a1b9d1bc7e38eb410f1c1bbd6991"
    }
  ],
  "numberOfEvents": 1
}
```

#### 15.3.4.2 On Humio:

- Create Action:

	* Use the Webbhook from EventManager/NOI
	* Select `Skip Certificate Validation`
	* Click `Test Action` and check that you get it in EventManager/NOI Events


- Create Alert:

	* 	With Query (for example):
	
		```json
		"kubernetes.container_name" = ratings
		| @rawstring = /error/i
		```

	* 	Time Window 2 seconds
	* 	1 second throttle window
	* 	Add action from above
	
	
	
---------------------------------------------------------------
# 16. ServiceMesh
---------------------------------------------------------------

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

You can easily install ServiceMesh/Istio into the same cluster as CP4WAIOPS.

This will instrument the RobotShop Application at the same time.

1. Launch

	```bash
	ansible-playbook ./ansible/29_install-servicemesh.yaml	```
2. Wait for the pods to come up
3. You can get the different URLs (RobotShop, Kibana, Grafana, Jaeger) by launching:

	```bash
	./tools/20_get_logins.sh > my_credentials.txt
	```


<div style="page-break-after: always;"></div>
