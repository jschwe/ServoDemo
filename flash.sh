#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$0")

set -eux

# User defined file!
source "${SCRIPT_DIR}/build.env"

# Build the .hap file with default settings.
hvigorw assembleHap
# Stop and uninstall any older versions of the servodemo.
hdc shell aa force-stop com.servo.demo
hdc uninstall com.servo.demo
# Create a temporary directory on the device and send the .hap file to the device
hdc shell mkdir data/local/tmp/servoshell-tmp
hdc file send entry/build/default/outputs/default/servoshell-default-signed.hap "/data/local/tmp/servoshell-tmp"
# Install the app
hdc shell bm install -p data/local/tmp/servoshell-tmp
# Clean-up the temporary folder
hdc shell rm -rf data/local/tmp/servoshell-tmp
# Optionally start the app from the command-line
# Note: You can also start the app on the phone by touching the servo app icon.
hdc shell aa start -a EntryAbility -b com.servo.demo
