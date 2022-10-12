# =====================
# Bucket to bucket copy
# =====================
#!/bin/bash
#set -x

# exporting environment and variables
export OCI_CLI_PROFILE=INTDBAASECRA
export OCICLIHOME=/usr/local/bin
export SBKT="rttes"
export TBKT="rttest"
export SRG="eu-amsterdam-1"
export TRG="uk-london-1"
export COMP="ocid1.compartment.oc1..aaaaaaaa7zdbbdmrxqkc57dcfr7g4xly2iollzem55ckv6pdaupyconsck2a"

SBKTLISTFILE=/tmp/sbucketlist
TBKTLISTFILE=/tmp/tbucketlist
OBJLISTFILE=/tmp/objlist

# fetching namespace
export NS=`oci os ns get | jq -r .data`
printf "\nINFO: namespace: $NS\n"

# listing source buckets
$OCICLIHOME/oci os bucket list -c $COMP --all --region $SRG | jq -r .data[].name > $SBKTLISTFILE

# validating source bucket
if [ -f "$SBKTLISTFILE" ]; then

    if [ -s $SBKTLISTFILE ]; then

        SBKTCOUNT=`grep -w $SBKT $SBKTLISTFILE | wc -l`

        if [[ $SBKTCOUNT -gt 0 ]]; then
            printf "INFO: source bucket $SBKT validated.\n"
        else
            printf "ERROR: unable to find the source bucket $SBKT in compartment $COMP (region: $SRG).\n"
            exit 1
        fi
    else
         printf "WARNING: $SBKTLISTFILE is Empty. Check the compartment $COMP for more details.\n"
    fi

else
    printf "ERROR: $SBKTLISTFILE does not exists.\n"
    exit 1
fi

# listing target buckets
$OCICLIHOME/oci os bucket list -c $COMP --all --region $TRG | jq -r .data[].name > $TBKTLISTFILE

# validating target bucket
if [ -f "$TBKTLISTFILE" ]; then

    if [ -s $TBKTLISTFILE ]; then

        TBKTCOUNT=`grep -w $TBKT $TBKTLISTFILE | wc -l`

        if [[ $TBKTCOUNT -gt 0 ]]; then
            printf "INFO: target bucket $TBKT validated.\n"
        else
            printf "ERROR: unable to find the target bucket $TBKT in compartment $COMP (region: $TRG).\n"
            exit 1
        fi
    else
         printf "WARNING: $TBKTLISTFILE is Empty. Check the compartment $COMP for more details.\n"
    fi

else
    printf "ERROR: $TBKTLISTFILE does not exists.\n"
    exit 1
fi

# listing objects
$OCICLIHOME/oci os object list -bn $SBKT --all | jq -r .data[].name > $OBJLISTFILE

# checking file existence
if [ -f "$OBJLISTFILE" ]; then

    printf "INFO: bucket contents offloaded to the file $OBJLISTFILE.\n"

    # checking file contents
    if [ -s $OBJLISTFILE ]; then

        printf "INFO: listing bucket contents and copying to the target location\n"
        printf "****\n"

        # listing objects
        for obj in $( cat $OBJLISTFILE )
        do
            LC="${obj: -1}"

            if [[ $LC =~ "/" ]]
            then
                printf "INFO: processing $obj (folder)\n"
            else
                printf "INFO: processing $obj (file)\n"
            fi

            # copy to the mentioned bucket/region
            printf "INFO: copying $obj from $SRG to $TRG\n"
            $OCICLIHOME/oci os object copy -ns $NS --region $SRG -bn $SBKT --source-object-name $obj --destination-namespace $NS --destination-region $TRG --destination-bucket $TBKT

        done

    else
        printf "WARNING: $OBJLISTFILE is Empty. Check the bucket $SB for more details.\n"
    fi
else
    printf "ERROR: $OBJLISTFILE does not exists.\n"
    exit 1
fi
