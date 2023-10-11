#!/bin/bash

INSTANCE_NAME="kpmg-vm"
PROJECT_NAME="chet-kpmg-dev-npe"

# Fetch instance metadata
INSTANCE_METADATA=$(gcloud compute instances describe "$INSTANCE_NAME" --format json --project $PROJECT_NAME)

# Print instance metadata
echo "Instance Metadata for $INSTANCE_NAME :"
echo "$INSTANCE_METADATA"