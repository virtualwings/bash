# script for listing all the adb systems for all subscribed regions
export OCI_CLI_PROFILE=PAASDEVDBCSSI
#!/bin/bash
#set -x
# get the compartment list
for c in `oci iam compartment list --all | jq -r .data[].id`
do
  COMP=`oci iam compartment get -c $c |  jq -r '.data|.name'`
  # get the subscribed  regions
  for r in $(oci iam region-subscription list | jq -r '.data[]."region-name"')
  do
    printf "INFO: listing ADB systems under compartment: $COMP ($c) for region: $r\n"
    # list the dbsystems in table format
    oci db autonomous-database list -c $c --region $r --all --output table --query 'data [*].{NAME:"display-name",OCID:"id",CORECOUNT:"cpu-core-count",DATASTORAGESIZE:"data-storage-size-in-gbs"}'
  done
done
