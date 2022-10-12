#!/bin/bash
#
#set -x
export OCI_CLI_PROFILE=INTDBAASECRA
root_comp=`oci iam compartment list --all --compartment-id-in-subtree true --access-level ACCESSIBLE --include-root --raw-output --query "data[?contains(\"id\",'tenancy')].id | [0]"`
# printf "INFO: root compartment: $root_comp\n"
# list regions
for r in $(oci iam region list --all | jq -r '.data[].name')
do
 # printf "INFO: region: $r\n"
 # list availability domain
 oci iam availability-domain list -c $root_comp --region $r | jq -r '.data[].name'
done
