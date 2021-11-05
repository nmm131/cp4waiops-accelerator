# CP4WAIOPS Accelerator

## Anchors
[Installation dependencies](#installation-dependencies)

[Reserve a ROKS cluster](#reserve-a-roks-cluster)
- [Share access to the ROKS cluster](#share-access-to-the-roks-cluster)
- [TechZone support](#techzone-support)

[Clone this repository](#clone-this-repository)

[Delete your cluster](#delete-your-cluster)

[Limitations of this Project](#limitations-of-this-project)

[Definitions](#definitions)


## Installation dependencies
1. sh
2. OpenShift CLI
3. Red Hat OpenShift Container Platform

## Reserve a ROKS cluster
[Reserve a classic ROKS cluster](https://techzone.ibm.com/collection/custom-roks-vmware-requests)

Underneath `Environments` click on `IBM RedHat Openshift Kubernetes Service (ROKS)`

![TechZone](./documentation/techzone01.png)

Click `Reserve Now` to create your cluster. The cluster will take some time to provision and it will be available for up to seven days (168 hours).

![TechZone](./documentation/techzone02.png)

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

Click `Submit`

![TechZone](./documentation/techzone03.png)

Wait for your cluster to be provisioned. This can take anywhere from 15 minutes to about an hour.

The status of the reservation will turn green for `Scheduled` or `Provisioning`

![TechZone](./documentation/techzone04.png)

Then the status of the reservation will turn black for `Ready`

![TechZone](./documentation/techzone05.png)

### Share access to the ROKS cluster
[Login to TechZone](https://techzone.ibm.com/my/reservations)

Find the reservation that needs to be shared

Click on the three vertical dots menu

Select `Share`

![TechZone](./documentation/techzone06.png)

Enter the IBMid to share with

Click on `Share` blue button

![TechZone](./documentation/techzone07.png)

The cluster automatically become available to another user in IBM Cloud.

Once shared it can not be revoked. Only by DTE Admins per owner request.

Shared environment will remain visible in "My reservation" view to its owner only.

### TechZone support
For any questions, contact ITZ support.

Business Partners - Contact ITZ Support - `techzone.help@ibm.com`

IBMers - Make a post on the `#itz-techzone-support` slack channel.

## Clone this repository
Run the following command from the directory you want the repository to exist in:

```
git clone git@github.ibm.com:CP4WAIOPS-Accelerator/CP4WAIOPS.git
```

## Delete your cluster
[Delete your classic ROKS cluster](https://techzone.ibm.com/my/reservations)

Click the three dots icon in the top-right corner of your reservation

Click `Delete`

Your cluster will automatically be deleted from IBM Cloud

## Limitations of this Project

## Definitions
IBM RedHat Openshift Kubernetes Service (ROKS)