cmake_minimum_required(VERSION 3.20)
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
project(ServoDemo)

include(FetchContent)
FetchContent_Declare(
    Corrosion
    GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
    GIT_TAG master # We currently need the latest version
)
set(Rust_RUSTUP_INSTALL_MISSING_TARGET ON)
FetchContent_MakeAvailable(Corrosion)

set(SERVO_ROOT_DIR "/Users/jschwender/Dev/servo")
set(manifest_path "${SERVO_ROOT_DIR}/ports/servoshell/Cargo.toml")
cmake_path(ABSOLUTE_PATH manifest_path NORMALIZE)
message(STATUS "resolved path to ${manifest_path}")

corrosion_import_crate(
    MANIFEST_PATH "${manifest_path}"
    CRATES servoshell
    OVERRIDE_CRATE_TYPE "servoshell=cdylib"
    IMPORTED_CRATES imported_crates)

cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH llvm_bin_dir)
set(llvm_lib_dir "${llvm_bin_dir}/../lib")
cmake_path(ABSOLUTE_PATH llvm_lib_dir NORMALIZE)

corrosion_set_env_vars(servoshell
        HOST_CC=clang
        HOST_CXX=clang++
        TARGET_AR=${CMAKE_AR}
        TARGET_RANLIB=${CMAKE_RANLIB}
        TARGET_READELF=${CMAKE_READELF}
        TARGET_OBJCOPY=${CMAKE_OBJCOPY}
        TARGET_STRIP=${CMAKE_STRIP}
        CLANG_PATH=${CMAKE_CXX_COMPILER}
        LIBCLANG_PATH=${llvm_lib_dir}
        "TARGET_CFLAGS=${CMAKE_C_FLAGS} --sysroot=${CMAKE_SYSROOT}"
        "TARGET_CXXFLAGS=${CMAKEC_CXX_FLAGS} --sysroot=${CMAKE_SYSROOT}"
        "BINDGEN_EXTRA_CLANG_ARGS_${Rust_CARGO_TARGET}=${CMAKE_C_FLAGS} --sysroot=${CMAKE_SYSROOT}"
)

corrosion_add_target_local_rustflags(servoshell "-Clink-arg=--sysroot=${CMAKE_SYSROOT}")

