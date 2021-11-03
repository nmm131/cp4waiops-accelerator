# CP4WAIOPS Accelerator

## Installation dependencies
1. sh
2. OpenShift CLI
3. Red Hat OpenShift Container Platform

## Reserve a classic IBM RedHat Openshift Kubernetes Service (ROKS) cluster
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

![TechZone](./documentation/techzone04.png)

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
