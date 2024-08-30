#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
from time import time_ns
from typing import List

def run_hdc_shell_cmd(cmd: str):
    subprocess.run(['hdc', 'shell', cmd]).check_returncode()

def run_hdc_shell_cmd_with_output(cmd: str) -> str:
    res = subprocess.run(['hdc', 'shell', cmd], capture_output=True, encoding='utf-8')
    res.check_returncode()
    return res.stdout

def get_hdc_devices() -> List[str]:
    res = subprocess.run(['hdc', 'list', 'targets'], capture_output=True, encoding='utf-8')
    res.check_returncode()
    targets = [line.strip() for line in res.stdout.splitlines()]
    print("The following targets are connected: {targets}")
    return targets

def get_clang_abi() -> str:
    target_arch = run_hdc_shell_cmd_with_output("param get const.product.cpu.abilist").strip()
    abi_map = {
        "x86_64": "x86_64",
        "arm64-v8a": "aarch64",
        "armeabi-v7a": "armv7",
    }
    return abi_map[target_arch]


print("Running debug script")

target_output = subprocess.run(['hdc', 'list', 'targets'], capture_output=True, encoding='utf-8')
target_output.check_returncode()
if '[Empty]' in target_output.stdout:
    print("No devices connected. Exiting")
    exit(1)

lldb_target_root="/data/local/tmp/debugserver"
package_name="com.servo.demo"
target_arch=get_clang_abi()
clang_target_triple=f"{target_arch}-linux-ohos"
#if 'DEVECO_SDK_HOME' in os.environ:
#    sdk_home = Path(os.environ['DEVECO_SDK_HOME'])

sdk_home = Path("C:/Program Files/Huawei/DevEco Studio/sdk/")
is_harmonyOS = True

if is_harmonyOS:
    harmonyOS_version = "HarmonyOS-NEXT-DB3"
    sdk_dir = sdk_home.joinpath(harmonyOS_version)
    hms_sdk_dir = sdk_dir.joinpath("hms")
    oh_sdk_dir = sdk_dir.joinpath("openharmony")
    sdk_native_dir = hms_sdk_dir.joinpath("native")
else:
    print("Not implemented yet")
    raise NotImplementedError

assert sdk_native_dir.is_dir(), f"Expected to find SDK native dir at {sdk_native_dir}"


lldb_server_sdk_path = os.path.join(sdk_native_dir, "lldb", clang_target_triple, "lldb-server")
lldb_target_dir = lldb_target_root + "/" + package_name
target_lldb_server_path = f"{lldb_target_dir}/lldb-server"
run_hdc_shell_cmd(f"mkdir -p {lldb_target_dir}")
run_hdc_shell_cmd(f"chmod 757 {lldb_target_dir}")
subprocess.run(['hdc', 'file', 'send', lldb_server_sdk_path, target_lldb_server_path])
run_hdc_shell_cmd(f"chmod 755 {target_lldb_server_path}")

# Debug only
run_hdc_shell_cmd(f"{target_lldb_server_path} version")

# Todo: get abiliuty name from BM dump
ability_name = "EntryAbility"
MAX_SOCKET_DIR_LEN = 70
socket_dir = package_name[:MAX_SOCKET_DIR_LEN]
sock_name = "platform-{}.sock".format(int(time_ns() / 1000000))
socket_path = f"/{socket_dir}/{sock_name}"
debug_args = f'{target_lldb_server_path} platform --listen unix-abstract://{socket_path} --log-channels lldb process:gdb-remote --log-file {lldb_target_dir}/platform.log'
run_hdc_shell_cmd(f'aa process -a {ability_name} -b {package_name} -D "{debug_args}"')

# myDebugClient.getDevice().getSerialNumber()
# serial_number = "2MM0223B14017253" # "127.0.0.1:5555"
serial_number = get_hdc_devices()[0]

connect_url = f"unix-abstract-connect://[{serial_number}]{socket_path}"
print("")
print("Successfully started lldb platform server. Please open lldb and connect to:")
print(f"{connect_url}")