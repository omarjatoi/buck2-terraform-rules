load(":rules.bzl", "terraform_apply", "terraform_destroy", "terraform_fmt", "terraform_module", "terraform_plan", "terraform_validate")

def terraform_workspace(name, srcs, vars = {}, auto_approve = False, visibility = None):
    """Declare a Terraform workspace as a set of Buck2 targets.

    Creates the following sub-targets:
        :{name}           — terraform_apply    (buck2 build, produces outputs.json)
        :{name}-plan      — terraform_plan     (buck2 run)
        :{name}-validate  — terraform_validate (buck2 run)
        :{name}-destroy   — terraform_destroy  (buck2 run)
        :{name}-fmt       — terraform_fmt      (buck2 run)

    Args:
        name:         Workspace name.
        srcs:         List of .tf source files.
        vars:         Dict of Terraform input variables (written to buck.auto.tfvars.json).
        auto_approve: If True, destroy skips interactive confirmation (for CI).
        visibility:   Buck2 visibility specification.
    """
    module_name = name + "-module"

    terraform_module(
        name = module_name,
        srcs = srcs,
        vars = vars,
    )

    terraform_apply(
        name = name,
        module = ":" + module_name,
        visibility = visibility,
    )

    terraform_plan(
        name = name + "-plan",
        module = ":" + module_name,
        visibility = visibility,
    )

    terraform_validate(
        name = name + "-validate",
        module = ":" + module_name,
        visibility = visibility,
    )

    terraform_destroy(
        name = name + "-destroy",
        module = ":" + module_name,
        auto_approve = auto_approve,
        visibility = visibility,
    )

    terraform_fmt(
        name = name + "-fmt",
        visibility = visibility,
    )
