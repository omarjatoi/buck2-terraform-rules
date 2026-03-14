load("@prelude//rules.bzl", "bzl_library")

# Makes the whole ruleset dependable as a single target.
# Consumers can put this in their toolchain deps to ensure
# the rules are fetched and available.
bzl_library(
    name = "terraform_rules",
    srcs = [],
    deps = [
        "//terraform:rules",  # re-exports rules.bzl + providers.bzl + macros.bzl
    ],
    visibility = ["PUBLIC"],
)

# Convenience alias so consumers can write
# load("@terraform_rules//:defs.bzl", "terraform_workspace")
# instead of the full path if they prefer
export_file(
    name = "defs.bzl",
    src = "terraform/macros.bzl",
    visibility = ["PUBLIC"],
)
