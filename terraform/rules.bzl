load(":providers.bzl", "TerraformModuleInfo")

def _terraform_module_impl(ctx):
    srcs_dict = {}
    for src in ctx.attrs.srcs:
        srcs_dict[src.short_path] = src

    if ctx.attrs.vars:
        tfvars = ctx.actions.write_json("buck.auto.tfvars.json", ctx.attrs.vars)
        srcs_dict["buck.auto.tfvars.json"] = tfvars

    workspace = ctx.actions.symlinked_dir("workspace", srcs_dict)

    return [
        DefaultInfo(default_output = workspace),
        TerraformModuleInfo(workspace_dir = workspace),
    ]

terraform_module = rule(
    impl = _terraform_module_impl,
    attrs = {
        "srcs": attrs.list(attrs.source()),
        "vars": attrs.dict(key = attrs.string(), value = attrs.any(), default = {}),
    },
)

# Copies the workspace to a writable temp dir.
_SCRIPT_SETUP = """\
#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$1"
shift

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

cp -rL "$WORKSPACE_DIR"/. "$WORKDIR"/
cd "$WORKDIR"
"""

# Setup + provider cache + terraform init.
_SCRIPT_PREAMBLE = _SCRIPT_SETUP + """\
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

terraform init -input=false >&2
"""

# terraform plan
def _terraform_plan_impl(ctx):
    module_info = ctx.attrs.module[TerraformModuleInfo]

    script = ctx.actions.write(
        "plan.sh",
        _SCRIPT_PREAMBLE + 'terraform plan -input=false "$@"\n',
        is_executable = True,
    )

    return [
        DefaultInfo(),
        RunInfo(args = cmd_args(script, module_info.workspace_dir)),
    ]

terraform_plan = rule(
    impl = _terraform_plan_impl,
    attrs = {
        "module": attrs.dep(providers = [TerraformModuleInfo]),
    },
)

# terraform validate
def _terraform_validate_impl(ctx):
    module_info = ctx.attrs.module[TerraformModuleInfo]

    script = ctx.actions.write(
        "validate.sh",
        _SCRIPT_PREAMBLE + 'terraform validate "$@"\n',
        is_executable = True,
    )

    return [
        DefaultInfo(),
        RunInfo(args = cmd_args(script, module_info.workspace_dir)),
    ]

terraform_validate = rule(
    impl = _terraform_validate_impl,
    attrs = {
        "module": attrs.dep(providers = [TerraformModuleInfo]),
    },
)

# terraform apply — build action that produces outputs.json
def _terraform_apply_impl(ctx):
    module_info = ctx.attrs.module[TerraformModuleInfo]
    outputs_json = ctx.actions.declare_output("outputs.json")

    script = ctx.actions.write(
        "apply.sh",
        _SCRIPT_PREAMBLE + """\
OUTPUT_FILE="$1"
terraform apply -auto-approve >&2
terraform output -json > "$OUTPUT_FILE"
""",
        is_executable = True,
    )

    ctx.actions.run(
        cmd_args(script, module_info.workspace_dir, outputs_json.as_output()),
        category = "terraform_apply",
        local_only = True,
        allow_cache_upload = False,
    )

    return [
        DefaultInfo(default_output = outputs_json),
    ]

terraform_apply = rule(
    impl = _terraform_apply_impl,
    attrs = {
        "module": attrs.dep(providers = [TerraformModuleInfo]),
    },
)

# terraform destroy
def _terraform_destroy_impl(ctx):
    module_info = ctx.attrs.module[TerraformModuleInfo]

    cmd = "terraform destroy"
    if ctx.attrs.auto_approve:
        cmd += " -auto-approve"

    script = ctx.actions.write(
        "destroy.sh",
        _SCRIPT_PREAMBLE + cmd + ' "$@"\n',
        is_executable = True,
    )

    return [
        DefaultInfo(),
        RunInfo(args = cmd_args(script, module_info.workspace_dir)),
    ]

terraform_destroy = rule(
    impl = _terraform_destroy_impl,
    attrs = {
        "module": attrs.dep(providers = [TerraformModuleInfo]),
        "auto_approve": attrs.bool(default = False),
    },
)

# terraform fmt
def _terraform_fmt_impl(ctx):
    script = ctx.actions.write(
        "fmt.sh",
        """\
#!/usr/bin/env bash
set -euo pipefail
exec terraform fmt "$@"
""",
        is_executable = True,
    )

    return [
        DefaultInfo(),
        RunInfo(args = cmd_args(script)),
    ]

terraform_fmt = rule(
    impl = _terraform_fmt_impl,
    attrs = {},
)
