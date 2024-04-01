# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

load("@prelude//java:dex_toolchain.bzl", "DexToolchainInfo")
load("@prelude//cxx:headers.bzl", "HeaderMode")
load("@prelude//cxx:linker.bzl", "is_pdb_generated")
load("@prelude//linking:link_info.bzl", "LinkOrdering", "LinkStyle")
load("@prelude//linking:lto.bzl", "LtoMode")
load("@prelude//toolchains/msvc:tools.bzl", "VisualStudio")
load("@prelude//utils:cmd_script.bzl", "ScriptOs", "cmd_script")

def _system_dex_toolchain_impl(ctx: AnalysisContext):
    """
    A very simple toolchain that is hardcoded to the current environment.
    """
    archiver_args = ["ar"]
    archiver_type = "gnu"
    archiver_supports_argfiles = True
    # asm_compiler = ctx.attrs.compiler
    # asm_compiler_type = ctx.attrs.compiler_type
    if host_info().os.is_macos:
        archiver_supports_argfiles = False
        linker_type = "darwin"
    elif host_info().os.is_windows:
        msvc_tools = ctx.attrs.msvc_tools[VisualStudio]
        archiver_args = [msvc_tools.lib_exe]
        archiver_type = "windows"
        asm_compiler = msvc_tools.ml64_exe
        asm_compiler_type = "windows_ml64"
        if compiler == "cl.exe":
            compiler = msvc_tools.cl_exe
        cxx_compiler = compiler
        if cvtres_compiler == "cvtres.exe":
            cvtres_compiler = msvc_tools.cvtres_exe
        if rc_compiler == "rc.exe":
            rc_compiler = msvc_tools.rc_exe
        if linker == "link.exe":
            linker = msvc_tools.link_exe
        linker_type = "windows"
        binary_extension = "exe"
        object_file_extension = "obj"
        static_library_extension = "lib"
        shared_library_name_default_prefix = ""
        shared_library_name_format = "{}.dll"
        shared_library_versioned_name_format = "{}.dll"
    elif ctx.attrs.linker == "g++" or ctx.attrs.cxx_compiler == "g++":
        pass
    else:
        additional_linker_flags = ["-fuse-ld=lld"]

    return [
        DefaultInfo(),
        DexToolchainInfo(             
            # llvm_link = llvm_link,
        ),
    ]

system_dex_toolchain = rule(
    impl = _system_dex_toolchain_impl,
    attrs = {

        "jvm_args": attrs.list(attrs.string(), default = []),

     
        "rc_compiler": attrs.string(default = "rc.exe"),
        "rc_flags": attrs.list(attrs.string(), default = []),
    },
    is_toolchain_rule = True,
)
