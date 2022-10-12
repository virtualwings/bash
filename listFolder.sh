export OCI_CLI_PROFILE=OC1

#!/bin/bash
set -x

# ensure the folder is enclosed with in "/" and list the folders in /tmp/fList
for f in $(cat /tmp/fList)
do
  printf "\n"
  fc=`oci os object list -ns $1 -bn $2 --delimiter '/' --prefix "$f" | jq -r '.data | .[].name'|wc -l`
  printf "INFO: Total file count in folder $f : $fc\n\n"
  oci os object list -ns $1 -bn $2 --delimiter '/' --prefix "$f" --output table --query 'data [*].{NAME:"name",MODIFIED_ON:"time-modified"}'
  printf "\n"
done
