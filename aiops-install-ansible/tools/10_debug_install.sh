#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS 3.2 - Debug WAIOPS Installation
#
#
#  ©2021 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AIOps 3.2 - Debug WAIOPS Installation"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "

. ./tools/99_uninstall/3.2/uninstall-cp4waiops-resource-groups.props
export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

function check_array_crd(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep "AGE" || true) 

            if  ([[ ! $ELEMENT_OK =~ "AGE" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}

function check_array(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep $ELEMENT_NAME || true) 

            if  ([[ ! $ELEMENT_OK =~ "$ELEMENT_NAME" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}


export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')

EVTMGR_PARAMETER=$(cat ./00_config_cp4waiops.yaml|grep EVTMGR_NAMESPACE:)
EVTMGR_NAMESPACE=${EVTMGR_PARAMETER##*:}
EVTMGR_NAMESPACE=$(echo $EVTMGR_NAMESPACE|tr -d '[:space:]')


CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


echo "  Initializing......"
























































#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





menu_check_install_aimgr () {

    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Examining CP4WAIOPS AI Manager Installation for hints...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Installed Openshift Operator Versions"
      echo "--------------------------------------------------------------------------------------------"

      oc get -n $WAIOPS_NAMESPACE ClusterServiceVersion


    

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace ibm-common-services"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n ibm-common-services | grep -v "Completed" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods with Image Pull Errors in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      export IMG_PULL_ERROR=$(oc get pods -n $WAIOPS_NAMESPACE | grep "ImagePull")

      if  ([[ ! $IMG_PULL_ERROR == "" ]]); 
      then 
            echo "      ⭕ There are Image Pull Errors:"; 
            echo "$IMG_PULL_ERROR"
            echo ""
            echo ""

            echo "      🔎 Check your Pull Secrets:"; 
            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

            echo ""
            echo ""
            echo "ibm-aiops-pull-secret Pull Secret"
            oc get secret/ibm-aiops-pull-secret -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

      else
            echo "      ✅ OK: All images can be pulled"; 
      fi



      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Camel-K Handlers (Hack for 3.2 GA)"
      echo "--------------------------------------------------------------------------------------------"

    
      POD_STATUS=$(oc get po -n $WAIOPS_NAMESPACE | grep -handlers-) 
      if  ([[ $POD_STATUS =~ "0/" ]]); 
      then 
            echo "      ⭕ Camel-K Handlers cannot connect to Vault"; 
            echo "      ⭕ Run:"; 
            echo "      ⭕    oc patch vaultaccess/ibm-vault-access -p '{"spec":{"token_period":"760h"}}' --type=merge -n $WAIOPS_NAMESPACE";  
            echo ""
      else
            echo "      ✅ OK: Pod aiops-topology-cassandra-auth-secret-generator"; 

      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Cassandra Pull Secret (Hack for 3.2 GA)"
      echo "--------------------------------------------------------------------------------------------"

    
      POD_STATUS=$(oc get po -n $WAIOPS_NAMESPACE | grep aiops-topology-cassandra-auth-secret-generator) 
      if  ([[ $POD_STATUS =~ "Pull" ]]); 
      then 
            echo "      ⭕ aiops-topology-cassandra-auth-secret-generator Pod cannot pull image"; 
            echo "      ⭕ Run:"; 
            echo "      ⭕    oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-topology-service-account -p '{\"imagePullSecrets\": [{\"name\": \"ibm-entitlement-key\"}]}'";  
            echo "      ⭕    oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep ImagePull|awk '{print$1}') -n $WAIOPS_NAMESPACE";  
            echo ""
      else
            echo "      ✅ OK: Pod aiops-topology-cassandra-auth-secret-generator"; 

      fi





      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check IR Analytics Pull Secret (Hack for 3.2 GA)"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
            "aiops-ir-analytics-classifier-76f8649f94-85n2l"
            "aiops-ir-analytics-probablecause-997b4fd85-zk7dq"
            "aiops-ir-analytics-spark-master-866dd7b476-256l5"
            "aiops-ir-analytics-spark-pipeline-composer-6c9989f6bb-brdjq"
            "aiops-ir-analytics-spark-worker-7")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT | grep "Pull" || true) 
            if  ([[  $ELEMENT_OK =~ "Pull" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 25  - Patch IR Pull Secrets)";  
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done








      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check ZEN Operator"
      echo "--------------------------------------------------------------------------------------------"

      export ZEN_LOGS=$(oc logs $(oc get po -n ibm-common-services|grep ibm-zen-operator|awk '{print$1}') -n ibm-common-services)
      export ZEN_ERRORS=$(echo $ZEN_LOGS|grep -i error)
      export ZEN_FAILED=$(echo $ZEN_LOGS|grep -i "failed=0")
      export ZEN_READY=$(echo $ZEN_LOGS|grep -i "ok=2")

      if  ([[ $ZEN_FAILED == "" ]]); 
      then 
            echo "      ⭕ Zen has errors"; 
            echo "$ZEN_ERRORS"
            echo "      ⭕ (You may want to run option: 29  - Restart Zen Job)";  
            echo ""
      else
            if  ([[ $ZEN_READY == "" ]]); 
            then 
                  echo "      ⭕ Zen Operator is still running"; 
                  echo ""
            else
                  echo "      ✅ OK: ZEN Operator has run successfully"; 
            fi
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Topology"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
      "aiops-topology-merge"
      "aiops-topology-status"
      "aiops-topology-topology")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 22  - Patch AI Manager merge topology pod)";  
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done



   



      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Patches"
      echo "--------------------------------------------------------------------------------------------"

      INGRESS_OK=$(oc get namespace default -oyaml | grep ingress || true) 
      if  ([[ ! $INGRESS_OK =~ "ingress" ]]); 
      then 
            echo "      ⭕ Ingress Not Patched"; 
            echo "      ⭕ (You may want to run option: 23  - Patch/enable ZEN route traffic)";  
            echo ""
      else
            echo "      ✅ OK: Ingress Patched"; 

      fi


      PATCH_OK=$(oc get deployment aiops-topology-merge -n $WAIOPS_NAMESPACE -oyaml --ignore-not-found| grep "failureThreshold: 61" || true) 
      if  ([[ ! $PATCH_OK =~ "failureThreshold: 61" ]]); 
      then 
            echo "      ⭕ aiops-topology-merge Not Patched"; 
            echo "      ⭕ (You may want to run option: 22  - Patch evtmanager topology pods)";  
            echo ""
      else
            echo "      ✅ OK: evtmanager-topology-merge Patched"; 
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Routes"
      echo "--------------------------------------------------------------------------------------------"



      ROUTE_OK=$(oc get route job-manager -n $WAIOPS_NAMESPACE || true) 
      if  ([[ ! $ROUTE_OK =~ "job-manager" ]]); 
      then 
            echo "      ⭕ job-manager Route does not exist"; 
            echo "      ⭕ (You may want to run option: 12  - Recreate custom Routes)";  
            echo ""
      else
            echo "      ✅ OK: job-manager Route exists"; 
      fi

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Base Operators"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
            "aimanager-operator"
            "iaf-core-operator-controller-manager"
            "iaf-eventprocessing-operator-controller-manager"
            "iaf-flink-operator-controller-manager"
            "iaf-operator-controller-manager"
            "ibm-aiops-orchestrator"
            "ibm-common-service-operator"
            "ibm-elastic-operator-controller-manager")

      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
       echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 21  - Patch IAF)"; 
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Secondary Operators"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
           "aiopsedge-operator-controller-manager"
            "asm-operator"
            "camel-k-operator"
            "couchdb-operator"
            "ibm-cloud-databases-redis"
            "ibm-ir-ai-operator-controller-manager"
            "ibm-kong-operator"
            "ibm-postgreservice-operator-controller-manager"
            "ibm-secure-tunnel-operator"
            "ibm-watson-aiops-ui-operator-controller-manager"
            "ir-core-operator-controller-manager"
            "ir-lifecycle-operator-controller-manager")

      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
       echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 21  - Patch IAF)"; 
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done


  




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Jobs"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
            "aimanager-aio-create-secrets"
            "aimanager-aio-create-truststore"
            "$WAIOPS_NAMESPACE-postgres-postgresql-create-cluster"
            "$WAIOPS_NAMESPACE-postgresdb-postgresql-create-database"
            "create-secrets-job"
            "iaf-zen-tour-job"
            "iam-config-job"
            "post-aiops-resources"
            "post-aiops-translations"
            "post-aiops-update-user-role"
            "setup-nginx-job"
            "zen-metastoredb-certs"
            "zen-metastoredb-init"
            "zen-post-requisite-job"
            "zen-pre-requisite-job")

      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get job -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Job $ELEMENT not run successfully"; 
                  echo "      ⭕ (You may want to delete the Job to make it run again - this can take some time)";  
                  echo ""
            else
                  echo "      ✅ OK: Job $ELEMENT"; 

            fi

      done


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Secrets"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
            "ibm-aiops-couchdb-secret"
            "ibm-aiops-elastic-admin-secret"
            "ibm-aiops-elastic-secret"
            "ibm-aiops-flink-secret"
            "ibm-aiops-kafka-secret"
            "ibm-aiops-redis-secret"
            "zen-truststore"
            "aimanager-aio-tls"
            "aimanager-ibm-minio-access-secret"
            "aimanager-modeltrain-cert-secret"
            "$WAIOPS_NAMESPACE-cartridge-kafka-auth"
            "$WAIOPS_NAMESPACE-postgres-ibm-postgresql-auth-secret"
            "$WAIOPS_NAMESPACE-postgres-postgresql-conn-secret"
            "$WAIOPS_NAMESPACE-postgresdb-postgresql-$WAIOPS_NAMESPACE-secret"
            "$WAIOPS_NAMESPACE-postgresdb-postgresql-$WAIOPS_NAMESPACE-secret-alt")

      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get secret $ELEMENT -n $WAIOPS_NAMESPACE --ignore-not-found -oyaml  || true) 
            if  ([[ ! $ELEMENT_OK =~ "kind: Secret" ]]); 
            then 
                  echo "      ⭕ Secret $ELEMENT does not exist"; 
                  echo ""
            else
                  echo "      ✅ OK: Secret $ELEMENT"; 

            fi

      done




}




menu_check_INSTALL_EVTMGR () {

    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Examining CP4WAIOPS Event Manager Installation for hints...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Installed Openshift Operator Versions"
      echo "--------------------------------------------------------------------------------------------"

      oc get -n $EVTMGR_NAMESPACE ClusterServiceVersion




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $EVTMGR_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $EVTMGR_NAMESPACE | grep -v "Completed" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods with Image Pull Errors in Namespace $EVTMGR_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      export IMG_PULL_ERROR=$(oc get pods -n $EVTMGR_NAMESPACE | grep "ImagePull")

      if  ([[ ! $IMG_PULL_ERROR == "" ]]); 
      then 
            echo "      ⭕ There are Image Pull Errors:"; 
            echo "$IMG_PULL_ERROR"
            echo ""
            echo ""

            echo "      🔎 Check your Pull Secrets:"; 
            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $EVTMGR_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

            echo ""
            echo ""
            echo "ibm-aiops-pull-secret Pull Secret"
            oc get secret/ibm-aiops-pull-secret -n $EVTMGR_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

      else
            echo "      ✅ OK: All images can be pulled"; 
      fi








      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check NOI"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
      "evtmanager-ibm-hdm-analytics-dev-inferenceservice")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $EVTMGR_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 31  - Patch NOI inferenceservice pod)";  
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Topology NOI"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
      "evtmanager-topology-merge"
      "evtmanager-topology-status"
      "evtmanager-topology-topology")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $EVTMGR_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo "      ⭕ (You may want to run option: 32  - Patch NOI topology pods)";  
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done


   






      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Patches"
      echo "--------------------------------------------------------------------------------------------"



      PATCH_OK=$(oc get deployment aiops-topology-merge -n $EVTMGR_NAMESPACE -oyaml | grep "failureThreshold: 61" || true) 
      if  ([[ ! $PATCH_OK =~ "failureThreshold: 61" ]]); 
      then 
            echo "      ⭕ aiops-topology-merge Not Patched"; 
            echo "      ⭕ (You may want to run option: 22  - Patch evtmanager topology pods)";  
            echo ""
      else
            echo "      ✅ OK: evtmanager-topology-merge Patched"; 
      fi



}




menu_check_install_all () {
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  In depth Examining CP4WAIOPS Installation for hints...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Check official list from uninstaller...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

 
      CHECK_NAME=BEDROCK_CRDS
      CHECK_ARRAY=("${BEDROCK_CRDS[@]}")    
      check_array

      CHECK_NAME=CP4WAIOPS_CRDS
      CHECK_ARRAY=("${CP4WAIOPS_CRDS[@]}")    
      check_array

    
      CHECK_NAME=CP4WAIOPS_ELASTICSEARCH_CRDS
      CHECK_ARRAY=("${CP4WAIOPS_ELASTICSEARCH_CRDS[@]}")    
      check_array

    
      CHECK_NAME=CP4WAIOPS_SECURETUNNEL_CRDS
      CHECK_ARRAY=("${CP4WAIOPS_SECURETUNNEL_CRDS[@]}")    
      check_array

    
      CHECK_NAME=CAMELK_CRDS
      CHECK_ARRAY=("${CAMELK_CRDS[@]}")    
      check_array

    
      CHECK_NAME=KONG_CRDS
      CHECK_ARRAY=("${KONG_CRDS[@]}")    
      check_array


      CHECK_NAME=CP4WAIOPS_CONFIGMAPS
      CHECK_ARRAY=("${CP4WAIOPS_CONFIGMAPS[@]}")    
      check_array
      CHECK_NAME=CP4WAIOPS_CONFIGMAPS_INTERNAL
      CHECK_ARRAY=("${CP4WAIOPS_CONFIGMAPS_INTERNAL[@]}")    
      check_array
      CHECK_NAME=CP4WAIOPS_SERVICEACCOUNTS
      CHECK_ARRAY=("${CP4WAIOPS_SERVICEACCOUNTS[@]}")    
      check_array

    
      CHECK_NAME=CP4WAIOPS_MISC
      CHECK_ARRAY=("${CP4WAIOPS_MISC[@]}")    
      check_array

      CHECK_NAME=CP4WAIOPS_KAFKATOPICS_LABELS
      CHECK_ARRAY=("${CP4WAIOPS_KAFKATOPICS_LABELS[@]}")    
      check_array

      CHECK_NAME=CP4WAIOPS_LINKED_SECRETS
      CHECK_ARRAY=("${CP4WAIOPS_LINKED_SECRETS[@]}")    
      check_array_crd

      CHECK_NAME=CP4WAIOPS_SECRETS_LABELS
      CHECK_ARRAY=("${CP4WAIOPS_SECRETS_LABELS[@]}")    
      check_array

      CHECK_NAME=CP4WAIOPS_INTERNAL_SECRETS_LABELS
      CHECK_ARRAY=("${CP4WAIOPS_INTERNAL_SECRETS_LABELS[@]}")    
      check_array

    


    

    
      CHECK_NAME=CP4WAIOPS_POSTGRES_LABELS
      CHECK_ARRAY=("${CP4WAIOPS_POSTGRES_LABELS[@]}")    
      check_array

    
      CHECK_NAME=CP4WAIOPS_LEASE
      CHECK_ARRAY=("${CP4WAIOPS_LEASE[@]}")    
      check_array

    
    
      CHECK_NAME=IAF_CERTMANAGER
      CHECK_ARRAY=("${IAF_CERTMANAGER[@]}")    
      check_array

    
      CHECK_NAME=IAF_SECRETS
      CHECK_ARRAY=("${IAF_SECRETS[@]}")    
      check_array

    

    
      CHECK_NAME=IAF_CONFIGMAPS
      CHECK_ARRAY=("${IAF_CONFIGMAPS[@]}")    
      check_array

    

    
      CHECK_NAME=IAF_MISC
      CHECK_ARRAY=("${IAF_MISC[@]}")    
      check_array

    

   

}



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch IAF Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_patch_iaf () {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching IAF Subscriptions" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo "   Details are here: https://www.ibm.com/docs/en/cloud-paks/1.0?topic=issues-operator-pods-crashing-during-installation"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""
            echo "Patch IAF Resources for ROKS"


            echo  "Patching IBM Automation Foundation Subscriiption for ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace" 
            IAF_OP_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace || true) 
            while  ([[ ! $IAF_OP_EXISTS =~ "v1.2" ]]); do 
                  IAF_OP_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace || true)  
                  echo "      ⭕ IAF Core Subscription not present. Waiting for 10 seconds...." && sleep 10; 
            done

            echo "Backup IBM Automation ClusterServiceVersion for ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace"
                  oc get subscriptions.operators.coreos.com ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators -oyaml > ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace-backup.yaml
                  echo "      ✅ OK"
            echo ""

            echo "Patch IAF Core Subscription"
                  oc patch subscriptions.operators.coreos.com ibm-automation-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators --patch "$(cat ./tools/patches/ibm-automation-sub-patch.yaml)"  --type=merge || true 
                  echo "      ✅ OK"
            echo ""




            echo  "Patching IBM Automation Foundation Subscriiption for ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace" 
            IAF_CORE_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace || true) 
            while  ([[ ! $IAF_CORE_EXISTS =~ "v1.2" ]]); do 
                  IAF_CORE_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace || true)  
                  echo "      ⭕ IAF Core Subscription not present. Waiting for 10 seconds...." && sleep 10; 
            done

            echo "Backup IBM Automation ClusterServiceVersion for ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace"
                  oc get subscriptions.operators.coreos.com ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators -oyaml > ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace-backup.yaml
                  echo "      ✅ OK"
            echo ""

            echo "Patch IAF Core Subscription"
                  oc patch subscriptions.operators.coreos.com ibm-automation-core-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators --patch "$(cat ./tools/patches/ibm-automation-core-sub-patch.yaml)"  --type=merge || true 
                  echo "      ✅ OK"
            echo ""




            echo  "Patching IBM Automation Foundation Subscriiption for ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace" 
            IAF_EVENT_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace || true) 
            while  ([[ ! $IAF_EVENT_EXISTS =~ "v1.2" ]]); do 
                  IAF_EVENT_EXISTS=$(oc get subscriptions.operators.coreos.com -n openshift-operators ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace || true) 
                  echo "      ⭕ IAF Core Subscription not present. Waiting for 10 seconds...." && sleep 10; 
            done

            echo "Backup IBM Automation ClusterServiceVersion for ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace"
                  oc get subscriptions.operators.coreos.com ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators -oyaml > ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace-backup.yaml
                  echo "      ✅ OK"
            echo ""



            echo "Patch IAF Event Subscription"
                  oc patch subscriptions.operators.coreos.com ibm-automation-eventprocessing-v1.2-ibm-operator-catalog-openshift-marketplace -n openshift-operators --patch "$(cat ./tools/patches/ibm-automation-eventprocessing-sub-patch.yaml)"  --type=merge
                  echo "      ✅ OK"
            echo ""




        else
          echo "    ⚠️  Skipping"
          echo "--------------------------------------------------------------------------------------------------------------------------------"
          echo  ""    
          echo  ""
        fi

}



menu_patch_iaf_ai_operator () {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching IBM Automation ClusterServiceVersion for iaf-operator-controller-manager" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""

            IBM_AUTO_EXISTS=$(oc get ClusterServiceVersion -n openshift-operators ibm-automation.v1.2.0 || true) 
            while  ([[ ! $IBM_AUTO_EXISTS =~ "IBM Automation Foundation" ]]); do 
                  IBM_AUTO_EXISTS=$(oc get ClusterServiceVersion -n openshift-operators ibm-automation.v1.2.0 || true)  
                  echo "      ⭕ IBM Automation ClusterServiceVersion for iaf-operator-controller-manager not present. Waiting for 10 seconds...." && sleep 10; 
            done

            echo "Backup IBM Automation ClusterServiceVersion for iaf-eventprocessing-operator-controller-manager"
                  oc get ClusterServiceVersion ibm-automation.v1.2.0 -n openshift-operators -oyaml > ibm-automation.v1.2.0-backup.yaml
                  echo "      ✅ OK"
            echo ""


            echo "Patch IBM Automation ClusterServiceVersion for iaf-operator-controller-manager"
                  oc patch ClusterServiceVersion ibm-automation.v1.2.0 -n openshift-operators --patch "$(cat ./tools/patches/iaf-operator-controller-manager-patch.yaml)"  --type=merge
                  echo "      ✅ OK"
            echo ""

            echo "Delete iaf-operator-controller-manager Deployment (will be recreated by Operator)"
                  #oc delete deployment -n openshift-operators iaf-operator-controller-manager
                  echo "      ✅ OK"
            echo ""


            echo "Patch Resources for ROKS"
        else
          echo "    ⚠️  Skipping"
          echo "--------------------------------------------------------------------------------------------------------------------------------"
          echo  ""    
          echo  ""
        fi

}


menu_patch_iaf_eventprocessing () {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching IBM Automation ClusterServiceVersion for iaf-eventprocessing-operator-controller-manager" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""

            IBM_AUTO_EXISTS=$(oc get ClusterServiceVersion -n openshift-operators ibm-automation-eventprocessing.v1.2.0 || true) 
            while  ([[ ! $IBM_AUTO_EXISTS =~ "IBM Automation Foundation" ]]); do 
                  IBM_AUTO_EXISTS=$(oc get ClusterServiceVersion -n openshift-operators iibm-automation-eventprocessing.v1.2.0 || true)  
                  echo "      ⭕ IBM Automation ClusterServiceVersion for iaf-eventprocessing-operator-controller-manager not present. Waiting for 10 seconds...." && sleep 10; 
            done

            echo "Backup IBM Automation ClusterServiceVersion for iaf-eventprocessing-operator-controller-manager"
                  oc get ClusterServiceVersion ibm-automation-eventprocessing.v1.2.0 -n openshift-operators -oyaml > ibm-automation-eventprocessing.v1.2.0-backup.yaml
                  echo "      ✅ OK"
            echo ""



            echo "Patch IBM Automation ClusterServiceVersion for iaf-eventprocessing-operator-controller-manager"
                  oc patch ClusterServiceVersion ibm-automation-eventprocessing.v1.2.0 -n openshift-operators --patch "$(cat ./tools/patches/iaf-eventprocessing-operator-controller-manager-patch.yaml)"  --type=merge
                  echo "      ✅ OK"
            echo ""

            echo "Delete iaf-eventprocessing-operator-controller-manager Deployment (will be recreated by Operator)"
                  #oc delete deployment -n openshift-operators iaf-eventprocessing-operator-controller-manager
                  echo "      ✅ OK"
            echo ""


            echo "Patch Resources for ROKS"
        else
          echo "    ⚠️  Skipping"
          echo "--------------------------------------------------------------------------------------------------------------------------------"
          echo  ""    
          echo  ""
        fi

}







# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Restart the CP4WAIOPS Namespace
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_restart_namespace() {
    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Restarting Namespace $WAIOPS_NAMESPACE" 
    echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      read -p " ❗❓ Continue? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
          echo "   ✅ Ok, continuing..."
          echo ""
          echo ""
          echo ""
          echo ""

          echo " ❎  Restarting Namespace $WAIOPS_NAMESPACE" 
          oc delete pods -n $WAIOPS_NAMESPACE --all
          echo "      ✅ OK"
          
          echo ""
          echo ""
          echo ""
          echo  "   🔬 Waiting for all pods in $WAIOPS_NAMESPACE to restart."

          WAIOPS_PODS_COUNT_NOTREADY=$(oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed" | grep "0/" | wc -l || true)
          WAIOPS_PODS_COUNT_TOTAL=$(oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed" | wc -l || true) 

          while  ([[ ! $(($WAIOPS_PODS_COUNT_NOTREADY)) == 0 ]] || [[  $(($WAIOPS_PODS_COUNT_TOTAL)) < $WAIOPS_PODS_COUNT_EXPECTED ]] ); do 
                WAIOPS_PODS_COUNT_NOTREADY=$(oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed" | grep "0/" | wc -l || true) 
                WAIOPS_PODS_COUNT_TOTAL=$(oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed" | wc -l || true) 
                
                echo  "      ⭕ CP4WAIOPS: $(($WAIOPS_PODS_COUNT_NOTREADY)) Pods not ready ($(($WAIOPS_PODS_COUNT_TOTAL - $WAIOPS_PODS_COUNT_NOTREADY))/$(($WAIOPS_PODS_COUNT_TOTAL)))  (will be around $WAIOPS_PODS_COUNT_EXPECTED pods).. Waiting for 10 seconds...." && sleep 10; 
          done
          echo  "      ✅ OK"
          echo  ""

      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi

}



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch the SSL Certs for Slack
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_ssl_certs() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Recreating SSL Certs for Slack" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
          





      echo "   --------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀  Patching Certs, new method" 
      echo "   --------------------------------------------------------------------------------------------------------------------------------"

IAF_STORAGE=$(oc get AutomationUIConfig -n $WAIOPS_NAMESPACE -o jsonpath='{ .items[*].spec.storage.class }')
oc get -n $WAIOPS_NAMESPACE AutomationUIConfig iaf-system -oyaml > iaf-system-backup.yaml
oc delete -n $WAIOPS_NAMESPACE AutomationUIConfig iaf-system
cat <<EOF | oc apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: iaf-system
  namespace: $WAIOPS_NAMESPACE
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
rm iaf-system-backup.yaml


      echo "   --------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀  Patching Certs, old method first" 
      echo "   --------------------------------------------------------------------------------------------------------------------------------"

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
rm cert.crt
rm cert.key
rm ca.crt
rm external-tls-secret

NGINX_READY=$(oc get pod -n $WAIOPS_NAMESPACE | grep "ibm-nginx" | grep "0/1" || true) 
while  ([[  $NGINX_READY =~ "0/1" ]]); do 
    NGINX_READY=$(oc get pod -n $WAIOPS_NAMESPACE | grep "ibm-nginx" | grep "0/1" || true) 
    echo "      ⭕ Nginx not ready. Waiting for 10 seconds...." && sleep 10; 
done

oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep slack|awk '{print$1}') -n $WAIOPS_NAMESPACE --grace-period 0 --force

      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}




# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch EventManager Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_patch_evtmanager_inference_noi() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching EventManager Pods for NOI" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""

             echo "Patch evtmanager-ibm-hdm-analytics-dev-inferenceservice"
                 oc patch deployment evtmanager-ibm-hdm-analytics-dev-inferenceservice -n noi --patch-file ./tools/patches/evtmanager-inferenceservice-patch.yaml || true 
                 echo "      ✅ OK"
             echo ""


      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}




# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch EventManager Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_patch_merge_noi() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching Topology Merge Pod" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""


            # echo "Patch evtmanager-ibm-hdm-analytics-dev-inferenceservice"
            #     oc patch deployment evtmanager-ibm-hdm-analytics-dev-inferenceservice -n noi --patch-file ./yaml/waiops/patches/evtmanager-inferenceservice-patch.yaml || true 
            #     echo "      ✅ OK"
            # echo ""

            echo "Patch evtmanager-topology-merge"
                oc patch deployment evtmanager-topology-merge -n noi --patch-file ./tools/patches/evtmanager-topology-merge-patch.yaml || true 
                echo "      ✅ OK"
            echo

            echo "Patch evtmanager-topology-status"
                oc patch deployment evtmanager-topology-status -n noi --patch-file ./tools/patches/evtmanager-topology-status-patch.yaml || true 
                echo "      ✅ OK"
            echo

            echo "Patch evtmanager-topology-search"
                oc patch deployment evtmanager-topology-search -n noi --patch-file ./tools/patches/evtmanager-topology-search-patch.yaml || true 
                echo "      ✅ OK"
            echo

            echo "Patch evtmanager-topology-layout"
                oc patch deployment evtmanager-topology-layout -n noi --patch-file ./tools/patches/evtmanager-topology-layout-patch.yaml || true 
                echo "      ✅ OK"
            echo

      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}


# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch EventManager Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_patch_merge_aimanager() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching Topology Merge Pod" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""


            echo "Patch aiops-topology-merge"
                oc patch deployment aiops-topology-merge -n $WAIOPS_NAMESPACE --patch-file ./tools/patches/aiops-topology-merge-patch.yaml || true 
                echo "      ✅ OK"
            echo

            echo "Patch aiops-topology-search"
                oc patch deployment aiops-topology-search -n $WAIOPS_NAMESPACE --patch-file ./tools/patches/aiops-topology-search-patch.yaml || true 
                echo "      ✅ OK"
            echo

            echo "Patch aiops-topology-status"
                oc patch deployment aiops-topology-status -n $WAIOPS_NAMESPACE --patch-file ./tools/patches/aiops-topology-status-patch.yaml || true 
                echo "      ✅ OK"
            echo


            echo "Patch aiops-topology-layout"
                oc patch deployment aiops-topology-layout -n $WAIOPS_NAMESPACE --patch-file ./tools/patches/aiops-topology-layout-patch.yaml || true 
                echo "      ✅ OK"
            echo


      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch ZEN Ingress
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_enable_zen_traffic() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching ZEN Ingress Traffic" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""

            echo "Patch Ingress"
            oc patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]' 
            echo "     ✅ Ingress successfully patched"
            echo ""
      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Create Routes
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_routes() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching Create Custom Routes" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""
            echo "Create Strimzi Route"
                oc patch Kafka strimzi-cluster -n  $WAIOPS_NAMESPACE -p '{"spec": {"kafka": {"listeners": {"external": {"type": "route"}}}}}' --type=merge  || true
                echo "      ✅ OK"
            echo ""

            echo "Create Topology Routes"

            echo "  Create Topology Merge Route"
                    oc create route passthrough topology-merge -n $WAIOPS_NAMESPACE --insecure-policy="Redirect" --service=evtmanager-topology-merge --port=https-merge-api   || true
                echo "      ✅ OK"

            echo ""

            echo "  Create Topology Rest Route"
                    oc create route passthrough topology-rest -n $WAIOPS_NAMESPACE --insecure-policy="Redirect" --service=evtmanager-topology-rest-observer --port=https-rest-observer-admin   || true
                echo "      ✅ OK"

            echo "  Create Topology Topology Route"
                    oc create route passthrough topology-manage -n $WAIOPS_NAMESPACE --service=evtmanager-topology-topology --port=https-topology-api   || true
                echo "      ✅ OK"

            echo ""



            echo "Create Flink Job Manager Routes"

            echo "  Create Flink Job Manager Route"
                oc create route passthrough job-manager -n $WAIOPS_NAMESPACE --service=aimanager-ibm-flink-job-manager --port=8000  || true
                echo "      ✅ OK"

            echo ""

      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}



menu_restart_zen_operator() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Restart WAIOPS Operators" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then


            CP4AIOPS_CHECK_LIST=(
            "ibm-zen-operator")

            for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
                  echo "   Delete Pod $ELEMENT.."
                  oc delete pod $(oc get po -n ibm-common-services|grep $ELEMENT|awk '{print$1}') -n ibm-common-services --grace-period 0 --force|| true
                  echo "      ✅ OK: Pod $ELEMENT"; 
            done
      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}

incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
}



menu_restart_operators() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Restart WAIOPS Operators" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then


            CP4AIOPS_CHECK_LIST=(
            "iaf-ai-operator-controller-manager"
            "iaf-core-operator-controller-manager"
            "iaf-eventprocessing-operator-controller"
            "iaf-flink-operator-controller-manager"
            "iaf-operator-controller-manager"
            "ibm-aiops-orchestrator"
            "ibm-common-service-operator"
            "ibm-elastic-operator-controller-manager"
            "strimzi-cluster-operator-v0.19.0$")

            for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
                  echo "   Delete Pod $ELEMENT.."
                  oc delete pod $(oc get po -n openshift-operators|grep $ELEMENT|awk '{print$1}') -n openshift-operators --grace-period 0 --force|| true
                  echo "      ✅ OK: Pod $ELEMENT"; 
            done
      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Patch IR Pull Secrets
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu_patch_ir_pull() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Patching IR Pull Secrets" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
        read -p " ❗❓ Continue? [y,N] " DO_COMM
        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo ""
            echo ""

            echo "Patch evtmanager-ibm-hdm-analytics-dev-inferenceservice"
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-topology-service-account -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-worker -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-pipeline-composer -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-master -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-probablecause -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-classifier -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-lifecycle-eventprocessor-ep -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
                  oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep ImagePull|awk '{print$1}') -n $WAIOPS_NAMESPACE
                 echo "      ✅ OK"
             echo ""


      else
        echo "    ⚠️  Skipping"
        echo "--------------------------------------------------------------------------------------------------------------------------------"
        echo  ""    
        echo  ""
      fi
}





incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------------------------------------------"
}


clear



echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo " 🚀 CloudPak for Watson AIOPs - FIX INSTALL"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  ℹ️  This script provides several options to fix problems with CP4WAIOPS installations"
echo "  "
echo "  🎬 Start with Option 1 to gather some information and recommendations."
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "

#export LOGS_TOPIC=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep logs-$LOG_TYPE| awk '{print $1;}')


until [ "$selection" = "0" ]; do
  
  echo ""
  
  echo "  ✅ Gather Information (<-- START HERE)"
  echo ""      
  echo "    	1  - Check CP4WAIOPS AI Manager Installation                   - examining AI Manager Installation for hints (this is by no means complete)    "
  echo "    	2  - Check CP4WAIOPS Event Managaer Installation               - examining Event Manager Installation for hints (this is by no means complete)    "
  echo "    	3  - Check CP4WAIOPS Installation - in-depth                   - examining CP4WAIOPS Installation in-depth for hints (this is by no means complete)    "
  echo ""      
  echo ""      
  echo ""      
  echo ""      
  echo "  ⚠️  Troubleshoot Connections (Low-Danger Zone) "
  echo ""
  echo "    	11  - Troubleshoot/Recreate Certificates for Slack             - recreates ingress certificates if you get SSL error in Slack"
  echo "    	12  - Recreate custom Routes                                   - if the check above mentions missing routes"
  echo ""      
  echo ""      
  echo ""      
  echo "  ❗ Patch stuck AI Manager installations (Warning Zone) "                    
  echo ""
  echo "    	21  - Patch IAF                                                - if the IBM Automation Foundation does not come up try this"
  echo "    	22  - Patch AI Manager merge topology pod                      - if the topology-merge pod is crashlooping"
  echo "    	25  - Patch IR Pull Secrets                                    - if IR Pods have Image Pull Errors"
  echo "    	28  - Patch/enable ZEN route traffic                           - if ZEN related components are not coming up"
  echo "    	29  - Restart Zen Operator                                     - if Zen Operator Ansible Script has errors - (takes 15-20 minutes)"
  echo "" 
  echo "  ❗ Patch stuck Event Manager installations (Warning Zone) "                
  echo ""    
  echo "    	31  - Patch NOI inferenceservice pod                           - if the evtmanger pods are crashlooping"
  echo "    	32  - Patch NOI topology pods                                  - if the evtmanger pods are crashlooping"
  echo ""      
  echo ""      
  echo ""      
  echo "  💣 Restart Cluster Elements (Danger Zone)"
  echo ""
  echo "    	91  - Restart WAIOPS Operators                                - if everything above fails restart WAIOPS Operators "
  echo "    	92  - Restart CP4WAIOPS Namespace                             - if everything else fails restart $WAIOPS_NAMESPACE  (takes up to an hour)"
  echo "      "
  echo "      "
  echo "      "
  echo "    	0  -  Exit"
  echo ""
  echo ""
  echo "  Enter selection: "
  read selection
  echo ""
  case $selection in
    1 ) clear ; menu_check_install_aimgr  ;;
    2 ) clear ; menu_check_INSTALL_EVTMGR  ;;
    3 ) clear ; menu_check_install_all  ;;
    11 ) clear ; menu_ssl_certs  ;;
    12 ) clear ; menu_routes  ;;
    21 ) clear ; menu_patch_iaf  ;;
    22 ) clear ; menu_patch_merge_aimanager  ;;
    25 ) clear ; menu_patch_ir_pull  ;;
    28 ) clear ; menu_enable_zen_traffic  ;;
    29 ) clear ; menu_restart_zen_operator  ;;

    31 ) clear ; menu_patch_evtmanager_inference_noi  ;;
    32 ) clear ; menu_patch_merge_noi  ;;


    
    91 ) clear ;menu_restart_operators ;;
    92 ) clear ; menu_restart_namespace  ;;

    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


