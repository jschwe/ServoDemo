#!/usr/bin/env bash

set -eux

LLDB_TARGET_ROOT=/data/local/tmp/debugserver
PACKAGE_NAME=servo
# TODO: Get from env/hvigor
CLANG_TARGET_TRIPLE=aarch64-linux-ohos
# relative to SDK path
LLDB_SERVER_SDK_PATH=native/lldb/${CLANG_TARGET_TRIPLE}/lldb-server

if [[ -n "${DEVECO_SDK_HOME-}" ]]; then
  # Todo: get from env
  HOS_VERSION=HarmonyOS-NEXT-DB3
  # hdc seems to interpret the path as relative path, unless we use C:\\ instead of C:/
  BASH_PATH_FIX_SDK_HOM="${DEVECO_SDK_HOME/C:\//C:\\}"
  LLDB_SERVER_PATH="${BASH_PATH_FIX_SDK_HOM}/${HOS_VERSION}/hms/${LLDB_SERVER_SDK_PATH}"
  if [[ ! -f "${LLDB_SERVER_PATH}" ]]; then
    echo "lldb server not found in sdk"
    exit 1
  fi
else
  echo "OpenHarmony support not implemented yet"
  exit 1
fi

hdc shell "mkdir -p ${LLDB_TARGET_ROOT}/${PACKAGE_NAME}"
hdc shell "chmod 757 ${LLDB_TARGET_ROOT}/${PACKAGE_NAME}"
hdc file send "${LLDB_SERVER_PATH}" "${LLDB_TARGET_ROOT}/${PACKAGE_NAME}/lldb-server"
hdc shell "chmod 755 ${LLDB_TARGET_ROOT}/${PACKAGE_NAME}/lldb-server"
