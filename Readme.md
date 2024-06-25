# OpenHarmony Servo Demo application

A simple demo browser application for running [servo] on OpenHarmony.

### Development

The UI is defined in `src/main/ets/pages/Index.ets`.
In the future the build will likely be automatically done by CMake, but for now [servo] should be built in the upstream 
servo project by running:

```
cd /path/to/servo
source ohos.env
./mach build --target aarch64-unknown-linux-ohos
```

Currently building `servo` for OpenHarmony is known to work on Linux. There may be issues when building on Windows,
so for now it is recommended to build servo on a Linux machine and copy the shared library to the
`entry/libs/arm64-v8a/` directory in this project.

```
cp /path/to/servo/target/aarch64-unknown-linux-ohos/<profile>/libservoshell.so entry/libs/arm64-v8a/libservoshell.so
```

Hint: If you built servo with the `--release` flag, `<profile>` should be replaced with `release`, otherwise use `debug`.



[servo]: https://github.com/servo/servo
[OpenHarmony]: https://gitee.com/openharmony/docs/blob/master/en/OpenHarmony-Overview.md