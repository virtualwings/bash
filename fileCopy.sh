# ===========
# fileCopy.sh
# ===========
#!/bin/bash
set -x

export OCICLIHOME=/home/oci/bin
export SB=rttest
export DB=rttest

# declare an array of string with type
declare -a objList=("test/x.log" "test.log" )

# fetching namespace
export NS=`oci os ns get | jq -r .data`
printf "INFO: Namespace: $NS\n"

# iterate the string array using for loop
for obj in ${objList[@]}; do

    printf "INFO: processing $obj\n"

    # copy to the mentioned bucket/region
    printf "INFO: copying $obj to LHR\n"
    $OCICLIHOME/oci os object copy -ns $NS -bn $SB --source-object-name $obj --destination-namespace $NS --destination-region uk-london-1 --destination-bucket $DB
    printf ""

done
