# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

load("@prelude//java:java_toolchain.bzl", "JavaTestToolchainInfo", "JavaToolchainInfo")
load(
    "@prelude//java:java_toolchain.bzl",
    "JavaPlatformInfo",
    "JavaTestToolchainInfo",
    "JavaToolchainInfo",
    "PrebuiltJarToolchainInfo",
)

load("@prelude//cxx:headers.bzl", "HeaderMode")
load("@prelude//cxx:linker.bzl", "is_pdb_generated")
load("@prelude//linking:link_info.bzl", "LinkOrdering", "LinkStyle")
load("@prelude//linking:lto.bzl", "LtoMode")
load("@prelude//toolchains/msvc:tools.bzl", "VisualStudio")
load("@prelude//utils:cmd_script.bzl", "ScriptOs", "cmd_script")

def _system_java_toolchain_impl(ctx: AnalysisContext):
    """
    A very simple toolchain that is hardcoded to the current environment.
    """
    java_version = "1.8"
    javac = "/usr/bin/javac"
    java = "/usr/bin/java"
    compile_and_package = ctx.attrs.compile_and_package
    source_level = ctx.attrs.source_level
    javac_protocol = ctx.attrs.javac_protocol
    target_level = ctx.attrs.target_level
    jar_builder = ctx.attrs.jar_builder
    bootclasspath_8 = ["/lib"]
    class_abi_generator = "none"
    src_root_prefixes = ["com"]
    src_root_elements = ["com"]
    gen_class_to_source_map = "/usr/bin/jar"
    fat_jar = "/usr/bin/jar"
    
    return [
        DefaultInfo(),
        JavaToolchainInfo(   
            source_level = ctx.attrs.source_level,
            target_level = ctx.attrs.target_level,
            javac_protocol = ctx.attrs.javac_protocol,
            javac = ctx.attrs.javac,
            compile_and_package = ctx.attrs.compile_and_package,
            jar_builder = ctx.attrs.jar_builder,
            bootclasspath_8 = ctx.attrs.bootclasspath_8,
            class_abi_generator = ctx.attrs.class_abi_generator,
            src_root_prefixes = ctx.attrs.src_root_prefixes,
            src_root_elements = ctx.attrs.src_root_elements,
            gen_class_to_source_map = ctx.attrs.gen_class_to_source_map,
            fat_jar = ctx.attrs.fat_jar,
            java = ctx.attrs.java,
        ),
        JavaPlatformInfo(),
    ]
    
system_java_toolchain = rule(
    impl = _system_java_toolchain_impl,
    attrs = {

        "jvm_args": attrs.list(attrs.string(), default = []),
        "java_version": attrs.string(default = "1"),
        "source_level": attrs.bool(default = False),
        "target_level": attrs.bool(default = False),
        "javac_protocol": attrs.string(default = "classic"),
        "javac": attrs.string(default = "/usr/bin/javac"),
        "compile_and_package": attrs.string(default = "/usr/bin/jar"),
        "jar_builder": attrs.string(default = "/usr/bin/jar"),
        "bootclasspath_8": attrs.list(attrs.string(), default = ["/lib1"]),
        "class_abi_generator": attrs.default_only(attrs.dep(providers = [RunInfo], default = "prelude//python/tools:make_source_db")),
        "src_root_prefixes": attrs.list(attrs.string(), default = ["nag_src_root_prefixes"]),
        "src_root_elements": attrs.list(attrs.string(), default = ["nag_src_root_elements"]),
        "gen_class_to_source_map": attrs.string(default = "/usr/bin/jar"),
        "fat_jar": attrs.string(default = "/usr/bin/jar"),
        "java": attrs.string(default = "/usr/bin/java"),
     
    },
    is_toolchain_rule = True,
)
