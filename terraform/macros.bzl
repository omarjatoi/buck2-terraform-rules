load(":rules.bzl", "terraform_apply", "terraform_destroy", "terraform_fmt", "terraform_module", "terraform_output", "terraform_plan", "terraform_validate")

def terraform_workspace(name, srcs, vars = {}, auto_approve = False, visibility = None):
    """Declare a Terraform workspace as a set of Buck2 targets.

    Creates the following sub-targets:
        :{name}           — terraform_module   (buck2 build, cacheable)
        :{name}-plan      — terraform_plan     (buck2 run)
        :{name}-validate  — terraform_validate (buck2 run)
        :{name}-apply     — terraform_apply    (buck2 run)
        :{name}-destroy   — terraform_destroy  (buck2 run)
        :{name}-fmt       — terraform_fmt      (buck2 run)
        :{name}-output    — terraform_output   (buck2 run)

    Args:
        name:       Workspace name.
        srcs:       List of .tf source files.
        vars:         Dict of Terraform input variables (written to buck.auto.tfvars.json).
        auto_approve: If True, apply and destroy skip interactive confirmation (for CI).
        visibility:   Buck2 visibility specification.
    """
    terraform_module(
        name = name,
        srcs = srcs,
        vars = vars,
        visibility = visibility,
    )

    terraform_plan(
        name = name + "-plan",
        module = ":" + name,
        visibility = visibility,
    )

    terraform_validate(
        name = name + "-validate",
        module = ":" + name,
        visibility = visibility,
    )

    terraform_apply(
        name = name + "-apply",
        module = ":" + name,
        auto_approve = auto_approve,
        visibility = visibility,
    )

    terraform_destroy(
        name = name + "-destroy",
        module = ":" + name,
        auto_approve = auto_approve,
        visibility = visibility,
    )

    terraform_fmt(
        name = name + "-fmt",
        visibility = visibility,
    )

    terraform_output(
        name = name + "-output",
        module = ":" + name,
        visibility = visibility,
    )
