#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Load \"$INDEX_TYPE\" Indexes for $APP_NAME"
echo ""
echo "***************************************************************************************************************************************"



#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check Defaults
#--------------------------------------------------------------------------------------------------------------------------------------------

if [[ $APP_NAME == "" ]] ;
then
      echo "⚠️ AppName not defined. Launching this script directly?"
      echo "❌ Aborting..."
      exit 1
fi

if [[ $INDEX_TYPE == "" ]] ;
then
      echo "⚠️ Index Type not defined. Launching this script directly?"
      echo "❌ Aborting..."
      exit 1
fi


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "  🔐  Getting credentials"
echo "***************************************************************************************************************************************"
oc project $WAIOPS_NAMESPACE


export username=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export password=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)

export WORKING_DIR_ES="./tools/02_training/TRAINING_FILES/ELASTIC/$APP_NAME/$INDEX_TYPE"


echo "      ✅ OK"
echo ""
echo ""

export ES_FILES=$(ls -1 $WORKING_DIR_ES | grep "json")
if [[ $ES_FILES == "" ]] ;
then
      echo "      ❗ No Elasticsearch import files found"
      echo "      ❗    No Elasticsearch import files found to ingest in path $WORKING_DIR_LOGS"
      echo "      ❗    Please place them in the directory."
      echo "      ❌ Aborting..."
      exit 1
else
      echo "      ✅ OK - Log Files"
fi



#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "  🔗  Checking credentials"
echo "***************************************************************************************************************************************"

if [[ $username == "" ]] ;
then
      echo "❌ Could not get Elasticsearch Username. Aborting..."
      exit 1
else
      echo "      ✅ OK - Elasticsearch Username"
fi

if [[ $password == "" ]] ;
then
      echo "❌ Could not get Elasticsearch Password. Aborting..."
      exit 1
else
      echo "      ✅ OK - Elasticsearch Password"
fi



echo ""
echo ""
echo ""
echo ""


echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  "
echo "  🔎  Parameter for ElasicSearch Index Load for $APP_NAME"
echo "  "
echo "           🧰 Index Type                  : $INDEX_TYPE"
echo "  "
echo "           🙎‍♂️ User                        : $username"
echo "           🔐 Password                    : $password"
echo "  "
echo "  "
echo "           📂 Directory for Indexes       : $WORKING_DIR_ES"
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  🗄️  Indexes to be loaded"
echo "***************************************************************************************************************************************"
ls -1 $WORKING_DIR_ES | grep "json"
echo "  "
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"

echo ""
echo ""



echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Import Indexes
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  Launching Index Load" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""



echo "    ***************************************************************************************************************************************"
echo "      🛠️  Getting exising Indexes"
echo "    ***************************************************************************************************************************************"

export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $existingIndexes == "" ]] ;
then
      echo "❗ Please start port forward in separate terminal."
      echo "❗ Run the following:"
      echo "    while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done"
      echo "❌ Aborting..."
      exit 1
fi
echo "      ✅ OK"
echo ""
echo ""



export NODE_TLS_REJECT_UNAUTHORIZED=0

for actFile in $(ls -1 $WORKING_DIR_ES | grep "json"); 
do 

      echo "    ***************************************************************************************************************************************"
      echo "        🛠️  Uploading Index: ${actFile%".json"}" 
      echo "    ***************************************************************************************************************************************"

      if [[ $existingIndexes =~ "${actFile%".json"}" ]] ;
      then
            curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep ${actFile%".json"} | sort
            echo "⚠️  Index already exist in Cluster."
            read -p " ❗❓ Append or Replace? [r,A] " DO_COMM
            if [[ $DO_COMM == "r" ||  $DO_COMM == "R" ]]; then
                        read -p " ❗❓ Are you sure that you want to delete and replace the Index? [y,N] " DO_COMM
                        if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                              echo "   ✅ Ok, continuing..."
                              echo ""
                              echo ""
                              echo "    ***************************************************************************************************************************************"
                              echo "        ❌  Deleting Index: ${actFile%".json"}" 
                              echo "    ***************************************************************************************************************************************"
                              curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/${actFile%".json"}
                              echo ""
                              echo ""

                        else
                              echo "❌ Aborted"
                              exit 1
                        fi

            else
                  echo "   ✅ Ok, continuing..."
            fi

      fi



      elasticdump --input="$WORKING_DIR_ES/${actFile}" --output=https://$username:$password@localhost:9200/${actFile%".json"} --type=data --limit=1000;
      echo "   ✅  OK"
done

echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "      🛠️  Getting all Indexes"
echo "***************************************************************************************************************************************"
curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | sort
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"






echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Load \"$INDEX_TYPE\" Indexes for $APP_NAME"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"


