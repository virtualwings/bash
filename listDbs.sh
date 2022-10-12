# script for listing all the OCI dbsystems for all subscribed regions
# this will sort the list in terms of core count
#
export OCI_CLI_PROFILE=PAASDEVDBCSSI
#
#!/bin/bash
#set -x
#

# get the compartment list
for c in `oci iam compartment list --all | jq -r .data[].id`
do
  COMP=`oci iam compartment get -c $c |  jq -r '.data|.name'`
  # get the subscribed  regions
  for r in $(oci iam region-subscription list | jq -r '.data[]."region-name"')
  do
    printf "INFO: listing ADB systems under compartment: $COMP ($c) for region: $r\n"
    # list the dbsystems in table format
    oci db system list --query "reverse(sort_by(data[*],&\"cpu-core-count\")|[0:10].{NAME:\"display-name\",OCID:id,STATE:\"lifecycle-state\",NODES:\"node-count\",CORES:\"cpu-core-count\",DATASTORAGE:\"data-storage-size-in-gbs\"})" -c $c --region $r --all --output table
  done
done
