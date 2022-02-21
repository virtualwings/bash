# 
# check ping/ ICMP protocol:
# --------------------------
#!/bin/bash
# set -x

vhost="${1:-google.com}"
printf "$vhost\n\n"

ping -c 3 $vhost > /dev/null

if [[ $? -eq 0 ]]; then
  printf "Host $vhost is rechable\n\n"
  exit 0
else
  printf "Host $vhost is not rechable\n\n"
fi