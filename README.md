# CP4WAIOPS Accelerator

# Notes
We are using a python base image, but are not installing node

## Table of Contents
- [CP4WAIOPS Accelerator](#cp4waiops-accelerator)
- [Notes](#notes)
  - [Table of Contents](#table-of-contents)
  - [Installation dependencies](#installation-dependencies)
  - [Reserve a ROKS cluster](#reserve-a-roks-cluster)
    - [Share access to the ROKS cluster](#share-access-to-the-roks-cluster)
    - [Login to your cluster](#login-to-your-cluster)
      - [If you see Ingress status is Unknown](#if-you-see-ingress-status-is-unknown)
      - [Login to OpenShift web console](#login-to-openshift-web-console)
    - [TechZone support](#techzone-support)
  - [Install Cloud Pak for Watson AIOps and Demo App](#install-cloud-pak-for-watson-aiops-and-demo-app)
    - [Create a GitHub Token](#create-a-github-token)
    - [Clone the CP4WAIOPS Demo repository](#clone-the-cp4waiops-demo-repository)
    - [Configure a global pull-secret](#configure-a-global-pull-secret)
    - [Install prerequisites](#install-prerequisites)
    - [Run the installation script](#run-the-installation-script)
    - [Save Passwords and Credentials](#save-passwords-and-credentials)
    - [Log into IBM Automation](#log-into-ibm-automation)
  - [Configure Cloud Pak for Watson AIOps Demo Environment](#configure-cloud-pak-for-watson-aiops-demo-environment)
    - [Configure Applications and Topology](#configure-applications-and-topology)
      - [Create Kubernetes Observer for the Demo Applications](#create-kubernetes-observer-for-the-demo-applications)
      - [Create REST Observer to Load Topologies](#create-rest-observer-to-load-topologies)
      - [Create Merge Rules for Kubernetes Observer](#create-merge-rules-for-kubernetes-observer)
      - [Load Merge Topologies](#load-merge-topologies)
      - [Create AIOps Application](#create-aiops-application)
    - [Configure Event Manager](#configure-event-manager)
      - [Event Manager Webhooks](#event-manager-webhooks)
        - [Generic Demo Webhook](#generic-demo-webhook)
      - [Create grouping Policy](#create-grouping-policy)
      - [Create NOI Menu item - Open URL](#create-noi-menu-item---open-url)
  - [Training](#training)
    - [Train Log Anomaly - RobotShop](#train-log-anomaly---robotshop)
      - [Create Kafka Training Integration](#create-kafka-training-integration)
      - [Load Training Data into Kafka (Option 1: faster)](#load-training-data-into-kafka-option-1-faster)
      - [Create Training Definition](#create-training-definition)
      - [Train the model](#train-the-model)
      - [Enable Log Anomaly detection](#enable-log-anomaly-detection)
    - [Train Event Grouping](#train-event-grouping)
      - [Create Integration](#create-integration)
      - [Load Kafka Training Data](#load-kafka-training-data)
      - [Create Training Definition](#create-training-definition-1)
      - [Train the model](#train-the-model-1)
      - [Enable Event Grouping](#enable-event-grouping)
    - [Train Incident Similarity](#train-incident-similarity)
      - [Load Training Data directly into ElasticSearch](#load-training-data-directly-into-elasticsearch)
      - [Create Training Definition](#create-training-definition-2)
      - [Train the model](#train-the-model-2)
  - [Configure Runbooks](#configure-runbooks)
    - [Create Bastion Server](#create-bastion-server)
    - [Create the NOI Integration](#create-the-noi-integration)
      - [In NOI](#in-noi)
      - [Adapt SSL Certificate in Bastion Host Deployment.](#adapt-ssl-certificate-in-bastion-host-deployment)
    - [Create Automation](#create-automation)
      - [Connect to Cluster](#connect-to-cluster)
      - [RobotShop Mitigate MySql](#robotshop-mitigate-mysql)
    - [Create Runbooks](#create-runbooks)
    - [Add Runbook Triggers](#add-runbook-triggers)
  - [Slack integration](#slack-integration)
    - [Initial Slack Setup](#initial-slack-setup)
  - [Delete your cluster](#delete-your-cluster)
  - [Limitations of this Project](#limitations-of-this-project)
  - [Definitions](#definitions)
  - [Goals](#goals)
  - [Resources](#resources)


## Installation dependencies
1. sh
2. OpenShift CLI
3. Red Hat OpenShift Container Platform

## Reserve a ROKS cluster
[Reserve a classic ROKS cluster](https://techzone.ibm.com/collection/custom-roks-vmware-requests)

Underneath `Environments` click on `IBM RedHat Openshift Kubernetes Service (ROKS)`

![IBM Technology Zone](./documentation/techzone01.png)

Click `Reserve Now` to create your cluster. The cluster will take some time to provision and it will be available for up to seven days (168 hours).

![IBM Technology Zone](./documentation/techzone02.png)

Fill out your reservation with the following details:
1. Name: CP4WAIOPS Accelerator
2. Purpose: Practice / Self-Education
3. Purpose Description: Install and demo CP4WAIOPS on a ROKS cluster.
4. End Date and Time:
   - Select a Date: Select a date that falls seven days from today's date
   - Select a Time: Select a time that falls before your current time
5. Preferred Geography: Choose a location with the lowest Disk Usage, then location closest to you (e.g., Dallas 10 Disk Usage: 25%)
6. Worker Node Count: 5
7. Worker Node Flavor: 16 CPU x 64 GB
8. NFS Size: 2 TB
9. OpenShift Version: 4.7

| Key                  |                                                                                                        Value |
| :------------------- | -----------------------------------------------------------------------------------------------------------: |
| Name:                |                                                                                        CP4WAIOPS Accelerator |
| Purpose:             |                                                                                    Practice / Self-Education |
| Purpose Description: |                                                                Install and demo CP4WAIOPS on a ROKS cluster. |
| End Date and Time:   |     Select a date that falls seven days from today's date. Select a time that falls before your current time |
| Preferred Geography: | Choose a location with the lowest Disk Usage, then location closest to you (e.g., Dallas 10 Disk Usage: 25%) |
| Worker Node Count:   |                                                                                                            5 |
| Worker Node Flavor:  |                                                                                               16 CPU x 64 GB |
| NFS Size:            |                                                                                                         2 TB |
| OpenShift Version:   |                                                                                                          4.7 |

Click `Submit`

![IBM Technology Zone](./documentation/techzone03.png)

Wait for your cluster to be provisioned. This can take anywhere from 15 minutes to about an hour.

The status of the reservation will turn green for `Scheduled` or `Provisioning`

![IBM Technology Zone](./documentation/techzone04.png)

Then the status of the reservation will turn black for `Ready`

![IBM Technology Zone](./documentation/techzone05.png)

### Share access to the ROKS cluster
[IBM Technology Zone](https://techzone.ibm.com/my/reservations)

Find the reservation that needs to be shared

Click on the three vertical dots menu

Select `Share`

![IBM Technology Zone](./documentation/techzone06.png)

Enter the IBMid to share with

Click on `Share` blue button

![IBM Technology Zone](./documentation/techzone07.png)

The cluster automatically become available to another user in IBM Cloud.

Once shared it can not be revoked. Only by DTE Admins per owner request.

Shared environment will remain visible in "My reservation" view to its owner only.

### Login to your cluster
You will get an e-mail from IBM Technology Zone verifying that your environment is ready

Click on the `Cluster URL`

![IBM Cloud](./documentation/ibmcloud01.png)

#### If you see Ingress status is Unknown

Log in to IBM Cloud CLI

Click on your user profile

Click on `Log in to CLI and API`

![IBM Cloud](./documentation/ibmcloud02.png)

Copy the IBM Cloud CLI (e.g., `ibmcloud login -a https://cloud.ibm.com -u passcode -p <passcode_string>`)

Run it from a terminal

When prompted, select a region closest to your physical location

Get your Cluster Name or ID with the following command, or through the `Cluster URL` found in your e-mail from IBM Technology Zone:
```
ibmcloud ks cluster ls
```

Copy the Name or ID value

Run the following command, replacing `<cluster_name_or_ID>` with the value from the previous step
```
ibmcloud ks ingress status -c <cluster_name_or_ID>
```

Expected output:

```
OK
                     
Ingress Status:   healthy   
Message:          All Ingress components are healthy   

Component             Status    Type   
certificate manager   healthy   secret   
router-default        healthy   router  
```

If Ingress or Component Statuses are not `healthy` then contact ITZ support or look at [IBM's Containers Ingress Status documentation](https://cloud.ibm.com/docs/containers?topic=containers-ingress-status) for clues to solve the issue.

#### Login to OpenShift web console
Click on `OpenShift web console`
![IBM Cloud](./documentation/ibmcloud03.png)

![OpenShift Web Console](./documentation/openshift-web-console01.png)

Click on your IBM ID in the top-right hand corner

Then click on `Copy login command`

![OpenShift Web Console](./documentation/openshift-web-console02.png)

Click on `Display Token`

![OpenShift Web Console](./documentation/openshift-web-console03.png)

Copy the command and run it from a terminal. e.g.:
```
oc login --token=<token_code> --server=<server_url:port>

```

### TechZone support
For any questions, contact ITZ support.

Business Partners - Contact ITZ Support - `techzone.help@ibm.com`

IBMers - Make a post on the `#itz-techzone-support` slack channel.

## Install Cloud Pak for Watson AIOps and Demo App
### Create a GitHub Token
Verify your email address, if it hasn't been verified yet.

In the upper-right corner of any page, click your profile photo, then click Settings.

![GitHub Personal Access Token](./documentation/github-personal-access-token01.png)

In the left sidebar, click Developer settings.

![GitHub Personal Access Token](./documentation/github-personal-access-token02.png)

In the left sidebar, click Personal access tokens.

![GitHub Personal Access Token](./documentation/github-personal-access-token03.png)

Click Generate new token.

![GitHub Personal Access Token](./documentation/github-personal-access-token04.png)

Give your token a descriptive name.

![GitHub Personal Access Token](./documentation/github-personal-access-token05.png)

To give your token an expiration, select the Expiration drop-down menu, then click a default or use the calendar picker.

![GitHub Personal Access Token](./documentation/github-personal-access-token06.png)

Select the scopes, or permissions, you'd like to grant this token. To use your token to access repositories from the command line, select repo.

![GitHub Personal Access Token](./documentation/github-personal-access-token07.gif)

Click Generate token.

![GitHub Personal Access Token](./documentation/github-personal-access-token08.png)

![GitHub Personal Access Token](./documentation/github-personal-access-token09.png)

### Clone the CP4WAIOPS Demo repository
Run the following command from the directory you want the repository to exist in:

```
git clone git@github.ibm.com:NIKH/aiops-3.1.git
```

### Configure a global pull-secret
Run the following command from the project's root folder:
```
oc get secret -n openshift-config pull-secret -oyaml > pull-secret_backup.yaml
```
In OpenShift web console, go to Secrets in Namespace openshift-config

Open the pull-secretSecret

Select Actions/Edit Secret

Scroll down and click Add Credentials

Enter your Docker credentials

### Install prerequisites
```
brew install wget
brew install librdkafka
./13_install_prerequisites_mac.sh
```

### Run the installation script
[Get your IBM Entitled Registry key](https://myibm.ibm.com/products-services/containerlibrary)

Run the following command, replacing `<IBM_Entitlement_Key>` with the IBM Entitled Registry key that you obtained in the previous step:
```
./10_install_aiops.sh -t <IBM_Entitlement_Key>
```

This will install the following operators:

- Knative
- Strimzi
- CP4WAIOPS
- OpenLDAP
- Demo Apps
- Register LDAP Users
- Gateway
- Housekeeping
- Additional Routes (Topology, Flink, Strimzi)
- Create OCP User (serviceaccount demo-admin)
- Patch Ingress
- Adapt NGINX Certificates
- Adapt Slack Welcome message to /welcome

### Save Passwords and Credentials

Run the following command from the project's root folder:
```
./80_get_logins.sh > provided-credentials.txt
```

### Log into IBM Automation
1. Log into IBM Automation:
    1. Go to the provided URL that you can find in the `./provided-credentials` file from a web browser
    2. If you see a "Your connection is not private" message for the `cpd-<NAMESPACE>` url, click **Advanced**
    ![Screenshot](documentation/ibm-automation-1.png)
    2. Then click **Proceed to URL (unsafe)** at the bottom.
    ![Screenshot](documentation/ibm-automation-2.png)
    3. Repeat steps #1 and #2 for the "Your connection is not private" message for the the `cp-console` url
    4. On the **Login to IBM Automation** screen, click **IBM provided credentials (admin only)** and input your credentials that you can find in the `./provided-credentials` file
    ![Screenshot](documentation/ibm-automation-3.png)
    ![Screenshot](documentation/ibm-automation-4.png)
    5. It is strongly recommended that you change the initial password the first time that you log in to the web client.

## Configure Cloud Pak for Watson AIOps Demo Environment
### Configure Applications and Topology
#### Create Kubernetes Observer for the Demo Applications
Using this observer, you can define jobs that discover the services you run on Kubernetes, and display Kubernetes containers and the relationships between them.

- In the IBM Automation Dashboard go into `Define` / `Data and tool integrations` / `Advanced` / `Manage ObserverJobs` / `Add a new Job`
- Select `Kubernetes` / `Configure`
- Choose “local”
- Set Unique ID to `robot-shop`
- Set Datacenter to `demo`
- Set `Correlate` to `true`
- Set Namespace to `robot-shop`
- `Save`

#### Create REST Observer to Load Topologies
Use the REST Observer for obtaining topology data via REST endpoints.

- In the IBM Automation Dashboard go into `Define` / `Data and tool integrations` / `Advanced` / `Manage ObserverJobs` / `Add a new Job`
- Select `REST`/ `Configure`
- Choose `bulk_replace`
- Set Unique ID to `listenJob`
- Set Provider to `listenJob`
- `Save`

#### Create Merge Rules for Kubernetes Observer
Run the following command from the project's root folder:
```
./tools/5_topology/create-merge-rules.sh
```

#### Load Merge Topologies
Run the following command from the project's root folder:
```
./tools/5_topology/create-merge-topology-robotshop.sh
```
**NOTE:** This will load the overlay topology for RobotShop and create Merge Topologies for RobotShop.

Manually re-run the Kubernetes Observer to make sure that the merge has been done.

#### Create AIOps Application
- In the IBM Automation Dashboard go into `Operate` / `Application Management` 
- Click `Create Application`
- Select `robot-shop` namespace
- Click `Add to Application`
- Name your Application `RobotShop`
- Check `Mark as favorite`
- Click `Save`

### Configure Event Manager
#### Event Manager Webhooks
Create Webhooks in Event Manager for Event injection and incident simulation for the Demo.

The demo scripts (in the `demo` folder) give you the possibility to simulate an outage without relying on the integrations with other systems.

At this time it simulates:
- Git push event
- Log Events (Humio)
- Security Events (Falco)
- Instana Events
- Metric Manager Events (Predictive)
- Turbonomic Events
- CP4MCM Synthetic Selenium Test Events

##### Generic Demo Webhook
IBM® Netcool® Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments. It also incorporates strong event management capabilities, and leverages real-time alarm and alert analytics, combined with broader historic data analytics, to deliver actionable insight into the performance of services and their associated dynamic network and IT infrastructures.
Define the following Webhook in Event Manager (NOI): 

- `Administration` / `Integration with other Systems`
- `Incoming` / `New Integration`
- `Webhook`
- Name it `Demo Generic`
- Jot down the WebHook URL and copy it to the `NETCOOL_WEBHOOK_GENERIC` in the `00_config-secrets.sh`file
- Click on `Optional event attributes`
- Scroll down and click on the + sign for `URL`
- Click `Confirm Selections`

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

- Severity: `severity`
- Summary: `summary`
- Resource name: `nodename`
- Event type: `alertgroup`
- Url: `url`
- Description: `"URL"`

#### Create grouping Policy
- NetCool Web Gui --> `Insights` / `Scope Based Grouping`
- Click `Create Policy`
- `Action` select fielt `Alert Group`
- Toggle `Enabled` to `On`
- Save

#### Create NOI Menu item - Open URL

in the Netcool WebGUI

- Go to `Administration` / `Tool Configuration`
- Click on `LaunchRunbook`
- Copy it (the middle button with the two sheets)
- Name it `Launch URL`
- Replace the Script Command with the following code

	```javascript
	var urlId = '{$selected_rows.URL}';
	
	if (urlId == '') {
	    alert('This event is not linked to an URL');
	} else {
	    var wnd = window.open(urlId, '_blank');
	}
	```
- `Save`
- Go to `Administration` / `Menu Configuration`
- Select `alerts`
- Click on `Modify`
- Move `Launch URL` to the right column
- `Save`

## Training
### Train Log Anomaly - RobotShop
#### Create Kafka Training Integration
- In the IBM Automation Dashboard select `Operate`/`Data and tool integrations`
- Under `Kafka`, click on `Add Integration`
- Name it `HumioInject`
- Select `Data Source` / `Logs`
- Select `Mapping Type` / `Humio`
- Paste the following in `Mapping`:

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
	
- Toggle `Data Flow` to the `ON` position
- Select `Data feed for initial AI Training`
- Click `Save`

#### Load Training Data into Kafka (Option 1: faster)
Run the following command from the project's root folder:
	
	```bash
	cd ./training/TRAINING_FILES/KAFKA/robot-shop/logs
	unzip robotshop-12h.zip
	cd -
	./training/robotshop-train-logs.sh
	```
	This takes some time (20-60 minutes depending on your Internet speed).

#### Create Training Definition

- In the IBM Automation Dashboard select `Operate`/`AI model management`
- Select `Log anomaly detection`
- Select `Create Training Definition`
- Select `Add Data`
- Select `05/05/21` to `07/05/21` (**NOTE** Do not add this to the dates to filter out section)
- Click `Next`
- Name it `LogAnomaly`
- Click `Next`
- Click `Create`


#### Train the model
- In the training definition click on `Actions` / `Start Training`
- This will start a precheck that should tell you after a while that you are ready for training
- In the training definition click on `Actions` / `Deploy`

#### Enable Log Anomaly detection

- In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
- Under `Kafka`, click on `2 integrations`
- Select `HumioInject`
- Scroll down and select `Data feed for continuous AI training and anomaly detection`
- Switch `Data Flow` to `on`
- Click `Save`

### Train Event Grouping
#### Create Integration

- In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
- Under `Kafka`, click on `1 integration`
- Select `noi-default`
- Scroll down and select `Data feed for initial AI Training`
- Toggle `Data Flow` to the `ON` position
- Click `Save`

#### Load Kafka Training Data

First we have to create some Events to train on.

- Make sure that you have pasted the Webhook (Generic Demo Webhook) from above into the file `./00_config-secrets.sh` for the variable `NETCOOL_WEBHOOK_GENERIC`.
- Run the following command from the project's root folder for 2-3 minutes, then quit with `Ctrl-C`:
	
	```bash
	./training/robotshop-train-events.sh
	```

#### Create Training Definition

- In the IBM Automation Dashboard select `Operate`/`AI model management`
- Select `Event grouping service`
- Select `Create Training Definition`
- Select `Add Data`
- Select `Last 90 Days` but set the end date to tomorrow
- Click `Next`
- Name it `EventGrouping`
- Click `Next`
- Click `Create`


#### Train the model

- In the training definition click on `Actions` / `Start Training`
- After successful training you should get "Needs improvement."
- In the training definition click on `Actions` / `Deploy`

#### Enable Event Grouping

- In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
- Under `Kafka`, click on `1 integration`
- Select `noi-default`
- Scroll down and select `Data feed for continuous AI training and anomaly detection`
- Switch `Data Flow` to `on`

### Train Incident Similarity
#### Load Training Data directly into ElasticSearch
1. Run this command in a separate terminal window to gain access to the Elasticsearch cluster:

	```bash
	while true; do oc port-forward statefulset/$(oc get statefulset | grep es-server-all | awk '{print $1}') 9200; done
	```

1. Run the following command from the project's root folder:

	
	```bash
	./training/robotshop-train-incidents.sh
	```

	This should not take more than 15-20 minutes.

	If you get asked if you want to Replace or Append, choose Append.

1. Check if the training data has been loaded you can execute (make sure you're on your aiops project/namespace), run the following command from the project's root folder:
```bash
oc exec -it $(oc get po |grep aimanager-aio-ai-platform-api-server|awk '{print$1}') -- bash
```
and on the bash-4.4$ termianl run:
```
curl -u elastic:$ES_PASSWORD -XGET https://elasticsearch-ibm-elasticsearch-ibm-elasticsearch-srv.<YOUR WAIOPS NAMESPACE>.svc.cluster.local:443/_cat/indices  --insecure | grep incidenttrain | sort
```

You should get something like this (for 20210505 and 20210506):

```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4841  100  4841    0     0  28644      0 --:--:-- --:--:-- --:--:-- 28644
yellow open incidenttrain                        X6FAhONnRrGzHy9qOVIk8Q 1 1    139   0 142.9kb 142.9kb
```


#### Create Training Definition

- In the IBM Automation Dashboard select `Operate`/`AI model management`
- Select `Similar incidents`
- Select `Create Training Definition`
- Click `Next`
- Name it "SimilarIncidents"
- Click `Next`
- Click `Create`


#### Train the model

- In the training definition click on `Actions` / `Start Training`
- This will start a precheck that should tell you after a while that you are ready for training and start the training
- After successful training
- In the training definition click on `Actions` / `Deploy`

## Configure Runbooks
### Create Bastion Server

This creates a simple Pod with the needed tools (oc, kubectl) being used as a bastion host for Runbook Automation. 

```bash
oc apply -n default -f ./tools/6_bastion/create-bastion.yaml
```

### Create the NOI Integration

#### In NOI

- Go to  `Administration` / `Integration with other Systems` / `Automation Type` / `Script`
- Copy the SSH KEY

#### Adapt SSL Certificate in Bastion Host Deployment. 

- Select the `bastion-host` Deployment in Namespace `default`
- Adapt Environment Variable SSH_KEY with the key you have copied above.

### Create Automation
#### Connect to Cluster
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc login --token=$token --server=$ocp_url
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root
$token	 : Token from your login (from 80_get_logins.sh)	
$ocp_url : URL from your login (from 80_get_logins.sh, something like https://c102-e.eu-de.containers.cloud.ibm.com:32236)		
```

#### RobotShop Mitigate MySql
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


### Create Runbooks

- `Library` / `New Runbook`
- Name it `Mitigate RobotShop Problem`
- `Add Automated Step`
- Add `Connect to Cluster`
- Select `Use default value` for all parameters
- Then `RobotShop Mitigate Ratings`
- Select `Use default value` for all parameters
- Click `Publish`

### Add Runbook Triggers

- `Triggers` / `New Trigger`
- Name and Description: `Mitigate RobotShop Problem`
- Conditions
	- Name: RobotShop
	- Attribute: Node
	- Operator: Equals
	- Value: mysql-deployment or web
- Click `Run Test`
- You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
- Select `Mitigate RobotShop Problem`
- Click `Select This Runbook`
- Toggle `Execution` / `Automatic` to `off`
- Click `Save`

## Slack integration
### Initial Slack Setup 

For the system to work you need to setup your own secure gateway and slack workspace. It is suggested that you do this within the public slack so that you can invite the customer to the experience as well. It also makes it easier for is to release this image to Business partners

You will need to create your own workspace to connect to your instance of CP4WAOps.

Here are the steps to follow:

1. [Create Slack Workspace](./tools/3_slack/1_slack_workspace.md)
1. [Create Slack App](./tools/3_slack/2_slack_app_create.md)
1. [Create Slack Channels](./tools/3_slack/3_slack_channel.md)
1. [Create Slack Integration](./tools/3_slack/4_slack_integrate.md)
1. [Get the Integration URL - Public Cloud - ROKS](./tools/3_slack/5_slack_url_public.md) OR 
1. [Get the Integration URL - Private Cloud - Fyre/TEC](./tools/3_slack/5_slack_url_private.md)
1. [Create Slack App Communications](./tools/3_slack/6_slack_app_integration.md)
1. [Prepare Slack Reset](./tools/3_slack/7_slack_reset.md)

## Delete your cluster
[Delete your classic ROKS cluster](https://techzone.ibm.com/my/reservations)

Click the three dots icon in the top-right corner of your reservation

Click `Delete`

Your cluster will automatically be deleted from IBM Cloud

## Limitations of this Project

## Definitions
IBM RedHat Openshift Kubernetes Service (ROKS)

## Goals
Automated the installation
Create a demo app
Containerize the solution

## Resources
[Find the original documentation to install and configure a CP4WAIOPS Demo Environment here.](https://github.ibm.com/NIKH/aiops-3.1)