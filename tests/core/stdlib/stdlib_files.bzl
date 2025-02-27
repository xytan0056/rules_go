# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//go/private:providers.bzl", "GoStdLib")

def _pure_transition_impl(settings, attr):
    return {"//go/config:pure": True}

pure_transition = transition(
    implementation = _pure_transition_impl,
    inputs = ["//go/config:pure"],
    outputs = ["//go/config:pure"],
)

def _stdlib_files_impl(ctx):
    # When a transition is used, ctx.attr._stdlib is a list of Target instead
    # of a Target. Possibly a bug?
    libs = ctx.attr._stdlib[0][GoStdLib].libs
    runfiles = ctx.runfiles(files = libs)
    return [DefaultInfo(
        files = depset(libs),
        runfiles = runfiles,
    )]

stdlib_files = rule(
    implementation = _stdlib_files_impl,
    attrs = {
        "_stdlib": attr.label(
            default = "@io_bazel_rules_go//:stdlib",
            providers = [GoStdLib],
            cfg = pure_transition,  # force recompilation
        ),
        "_whitelist_function_transition": attr.label(
            default = "@bazel_tools//tools/whitelists/function_transition_whitelist",
        ),
    },
)
