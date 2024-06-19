#!/bin/bash

curl -s https://ec2build.mdthink.maryland.gov/mdt-repo-udbuilds-scripts/MDT_BASE/Preamble.sh -o /root/Preamble.sh

chmod 755 /root/Preamble.sh

/root/Preamble.sh

. /root/.env

/root/git/MDT_BASE/mdt-base_user-data-git.sh FIPS