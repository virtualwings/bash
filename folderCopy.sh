# ==============
# folderCopy.sh
# ==============
#!/bin/bash
#set -x

export OCI_CLI_PROFILE=INTDBAASECRA
export OCICLIHOME=/usr/local/bin
export SB=rttest
export DB=rttest

OBJLISTFILE=/tmp/objlist
FPREFIX="test/"

export NS=`oci os ns get | jq -r .data`
printf "INFO: Namespace: $NS\n"

$OCICLIHOME/oci os object list -bn=$SB --prefix $FPREFIX --all | jq -r .data[].name > $OBJLISTFILE

if [ -f "$OBJLISTFILE" ]; then

    printf "INFO: folder contents/ files offloaded to the file $OBJLISTFILE.\n"

    if [ -s /tmp/objlist ]; then

        printf "INFO: Listing bucket contents and copying to the target location\n"

        # listing objects
        for obj in $( cat /tmp/objlist )
        do
            LC="${obj: -1}"

            if [[ $LC =~ "/" ]]
            then
                printf "INFO: processing $obj (folder)\n"
            else
                printf "INFO: processing $obj (file)\n"
            fi

            # copy to the mentioned bucket/region

            printf "INFO: copying $obj to LHR\n"
            $OCICLIHOME/oci os object copy -ns $NS -bn $SB --source-object-name $obj --destination-namespace $NS --destination-region uk-london-1 --destination-bucket $DB

        done

    else
        printf "WARNING: $OBJLISTFILE is Empty. Check the bucket $SB for more details.\n"
    fi
else
    printf "ERROR: $OBJLISTFILE does not exists.\n"
    exit 0
fi
