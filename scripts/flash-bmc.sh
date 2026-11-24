#!/bin/bash
# Flash a new firmware image onto a BMC.
# Usage: flash-bmc.sh <bmc-host> <image-url> [update-options]
set -e

BMC=$1
URL=$2
OPTS=$3

# Download the image.
curl -k -s -o /tmp/bmc-image.tar "$URL"

# Copy it to the BMC and start the update.
scp -o StrictHostKeyChecking=no /tmp/bmc-image.tar root@$BMC:/tmp/images/
ssh -o StrictHostKeyChecking=no root@$BMC "fw-update /tmp/images/bmc-image.tar $OPTS"

# Log the result.
eval "echo Flashed $URL to $BMC >> /var/log/bmc-flash.log"
