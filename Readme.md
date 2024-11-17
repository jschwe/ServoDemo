# OpenHarmony Servo Demo application

A simple demo browser application for running [servo] on OpenHarmony.

## ServoDemo ArkTS app

Similar to android and iOS, OpenHarmony apps also require some amount of glue code in the platform language - ArkTS.
This repository contains exactly this glue code. In the future the repo will likely be integrated into the upstream
servo repo.

## Usage

If you are on Windows or MacOS, you can simply open this repository in the [DevEco Studo] IDE, which will automatically
take care of generating signing keys etc. If you are on a Linux machine please checkout the section on
[Compiling and Signing the ServoDemo app for HarmonyOS on Linux machines](#compiling-and-signing-the-servodemo-app-for-harmonyos-on-linux-machines).

### Preferences

Servo can be configured by editing `AppScope/resources/resfile/prefs.json`.
This allows you to enable or disable different feature.
For example on HarmonyOS NEXT devices you need to disable the JIT feature, otherwise servo will crash on startup:

```json
"js.disable_jit": true,
```



### Building `libservoshell.so`

Currently `libservoshell.so` needs to be manually built and copied to the correct location in this project.
You will need to checkout and build the upstream [servo] project
for OpenHarmony. This currently needs to be done on a Linux or MacOS machine!

In the ServoDemo root folder run the following command to create the directory for the `libservoshell.so`.
This Guide assumes that you want to target 64-bit ARM Harmony OS devices.

```
mkdir -p entry/libs/arm64-v8a/
```


In a different directory clone the servo project:

```
git clone https://github.com/servo/servo
cd servo
cp servobuild.example .servobuild
```

Open the `.servobuild` file in the servo folder, and specify the path to the OpenHarmony SDK `native` directory.
```
[ohos]
ndk = "/path/to/ohos-sdk/<linux|mac>/native"
```
Currently OpenHarmony 4.0 or newer is supported.

You can then build servoshell for OpenHarmony by running:

```
./mach build --target=aarch64-unknown-linux-ohos --release
```

Building in release mode (by passing --release) is recommended, since the debug version is both slow and large.
You can find the `libservoshell.so` in the `target` directory of servo, and need to copy it to `/path/to/ServoDemo/entry/libs/arm64-v8a/libservoshell.so.
Please replace `<profile>` in the command below with `release` or `debug`, depending on the cargo profile you compiled the `so` with. :

```
cp /path/to/servo/target/aarch64-unknown-linux-ohos/<profile>/libservoshell.so entry/libs/arm64-v8a/libservoshell.so
```

In the future the build procedure may be automated more.

## Building the .hap app with DevEco Studio (Windows and Mac only)

After you have copied the `libservoshell.so` to the correct location, you can simply connect your device to your computer, or start the
HarmonyOS emulator and click the "Run" button on the top to build and flash the .hap app.
That should automatically package and flash the app to your phone.
Please note that you need to login first with your Huawei Developer ID, to generate signing keys. You can login by clicking on the 
profile button in the top right corner.

## Compiling and Signing the ServoDemo app for HarmonyOS on Linux machines

DevEco Studio is not available for Linux machines yet, but you can still compile and sign from the command-line after some initial setup.
Note, that as far as I know you will still need access to a windows or mac macine with DevEco Studio at least once to generate
the signing keys needed when flashing apps to a Harmony OS device.

### Setup and dependencies 

Download the [Command Line Tools for HarmonyOS NEXT]. Note that as of Developer Beta 1, this still requires
logging in with a registered and verified Chinese Huawei ID, registering for the Huawei Developer account 
and doing the real-name developer account verification.
If you are not a chinese national, you will still see the download button, but clicking it will have no
effect.

Extract the command line tools to a directory of your choice, and setup the following environment-variables
```
export DEVECO_SDK_HOME=/path/to/command-line-tools/sdk
export NODE_HOME=/path/to/command-line-tools/tool/node
```

For your convenience I would also recommend to add the necessary tools to your PATH:

```
# hvigorw is the build tool wrapper
export PATH=/path/to/command-line-tools/hvigor/bin:$PATH
# Add `hdc` to path (like adb for android)
export PATH=/path/to/command-line-tools/sdk/HarmonyOS-NEXT-DB1/openharmony/toolchains/:$PATH
```

Generate signing keys with DevEco Studio (on a windows or mac machine) and copy the keys from `$HOME/.ohos/config`
to the same location on your Linux machine. 
Copy the `signingConfigs` field in the `build-profile.json5` to your Linux machine, but take care to not commit the 
configuration to git, since it contains sensitive information such as the Password for the signing key.
Adjust the absolute paths in the `signingConfigs` to your target machine.

After that running `hvigorw assembleHap` should succeed.

### Building, signing and flashing the ServoDemo app on Linux

Once you have the [Command Line Tools for HarmonyOS NEXT] installed, you can just manually run the commands that DevEco Studio 
executes under the hood. 

1. Build the app

```
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
```

[servo]: https://github.com/servo/servo
[OpenHarmony]: https://gitee.com/openharmony/docs/blob/master/en/OpenHarmony-Overview.md
[DevEco Studo]: https://developer.huawei.com/consumer/cn/deveco-studio
[Command Line Tools for HarmonyOS NEXT]://developer.huawei.com/consumer/cn/download/
