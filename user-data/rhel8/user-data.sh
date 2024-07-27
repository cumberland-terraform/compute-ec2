#!/bin/bash

curl -s https://ec2build.mdthink.maryland.gov/mdt-repo-udbuilds-scripts/MDT_BASE/Preamble_RH8.sh -o /root/Preamble.sh

chmod 755 /root/Preamble.sh

/root/Preamble.sh

. /root/.env

/root/git/MDT_BASE/mdt-base_user-data_RH8.sh FIPS