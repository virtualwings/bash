#!/bin/bash
# set -x
#
# Permission: chmod 750 deleteFromOSS.sh
# Usage: ./deleteFromOSS.sh <namespace> <bucket>
#
# Version: 1.1.0
# Ownership: DBaaS VMBM SRE Team
#
# Last updated on: 07/10/2022
#

export OCI_CLI_PROFILE=OC1

# check the parameter value
if [[ -z $1 && -z $2 ]]; then
    printf "\n"
    printf "ERROR: No arguments passed. Arguments should not be NULL.\n"
    printf "INFO: Script usage:- ./deleteFromOSS.sh <namespace> <bucket>\n"
    exit 1
elif [[ -z $1 || -z $2 ]]; then
    printf "\n"
    printf "ERROR: Missing argument. Arguments should not be NULL.\n"
    printf "INFO: Script usage:- ./deleteFromOSS.sh <namespace> <bucket>\n"
    exit 1
else
    printf "\n"
    printf "\nINFO: Namespace entered: $1\n";
    printf "INFO: Target bucket name: $2\n\n";

    folderLevels=/tmp/folderLevels
    currentFolderLevel=/tmp/currentFolderLevel

    > $folderLevels
    > $currentFolderLevel

    # printing first four levels
    oci os object list -ns $1 -bn $2 --delimiter '/' --prefix 'file_chunk/' | jq -r .prefixes[] >> $currentFolderLevel
    echo "# INFO: level 0" >> $folderLevels
    oci os object list -ns $1 -bn $2 --delimiter '/' --prefix "file_chunk/" | jq -r .prefixes[] >> $folderLevels
    echo "" >> $folderLevels

    for levelCount in {1..3}
    do
        echo "# INFO: level $levelCount" >> $folderLevels
        #echo "" >> $folderLevels
        for folderLevel in $(cat $currentFolderLevel)
        do
            oci os object list -ns $1 -bn $2 --delimiter '/' --prefix "$folderLevel" | jq -r .prefixes[] >> $folderLevels
            oci os object list -ns $1 -bn $2 --delimiter '/' --prefix "$folderLevel" | jq -r .prefixes[] > $currentFolderLevel
        done
        echo "" >> $folderLevels
    done

    cat $folderLevels
fi

# deleting folders/ backup pieces mentioned with prefix
while true
do
    read -p "Do you wish to procced with deletion? [y/N]: " choice
    printf "\n"
    case $choice in
         [yY][eE][sS]|[yY])
            # printf "INFO: selected y/Yes\n"
            printf "\n"
            printf "INFO: Select the target folder level/ prefix for deletion from the above list.\n"
            printf "\n"
            printf "+------------------------------------------------------------------------------------------\n"
            printf "ALERT: Sub folders/ backup pieces under the selected folder level will be deleted.\n"
            printf "       The customer must be informed and we should take a customer consent before deletion.\n"
            printf "+------------------------------------------------------------------------------------------\n"
            printf "\n"

            read -p "Enter the target folder level/ prefix: " prefix

            if [ -z "$prefix" ]
            then
                printf "\n"
                printf "ERROR: Invalid folder level/ prefix. Target foler level/ prefix should not be NULL.\n"
                exit 1
            else
                printf "INFO: Target folder level/ prefix is NOT NULL\n"
            fi

            #prefixCount=`grep -w $prefix $folderLevels | wc -l`
            prefixCount=`grep $prefix $folderLevels | wc -l`

            if [[ $prefixCount -gt 0 ]]; then

                printf "INFO: target folder level/ prefix validated.\n"
                printf "INFO: folder level/ prefix - $prefix - has $prefixCount occurrence in $folderLevels.\n"

            else
                printf "\n"
                printf "ERROR: invalid folder level/ prefix. Enter a valid folder level/ prefix.\n"
                exit 1
            fi

            printf ""
            printf "INFO: target list of folder(s)/ file(s) for deletion\n\n"

            oci os object bulk-delete -ns $1 -bn $2 --prefix $prefix --dry-run | jq -r

            printf "\n"
            printf "+------------------------------------------------------------------------------------------------------------------------------\n"
            printf "WARNING: Are you sure you want to permanently delete the mentioned list of the folder(s)/ file(s) from the Object Storage?\n"
            printf "         This is irreversible and can cause inconsistency in Database Recovery if the backup pieces are a part of valid backup.\n"
            printf "+------------------------------------------------------------------------------------------------------------------------------\n"
            printf "\n"

            printf "\n"
            read -p "Proceed with deletion? [y/N]: " confirmation
            printf "\n"

            if [[ "$confirmation" =~ ^([yY][eE][sS]|[yY])$ ]]
            then
                printf "INFO: Deleting backup pieces with prefix: $prefix\n"
                printf "\n"

                oci os object bulk-delete -ns $1 -bn $2 --prefix $prefix --force

                printf "INFO: Deleted successfully.\n"
                printf "\n"

            else
                printf "$confirmation"
                exit 1
            fi
            ;;
         [nN][oO]|[nN])
            printf "INFO: Selected n/No. Exiting..\n\n"
            exit
            ;;
        *)
            printf "WARNING: Please select a valid option [y/N].\n\n"
            ;;
    esac
done

# Pending ***
# namespace validation
# bucket validation
# null response
# target folder/ file name validation
# listing files again after deletion
