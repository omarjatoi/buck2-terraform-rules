def _run_with_outputs_impl(ctx):
    outputs = []
    for dep in ctx.attrs.deps:
        outputs.extend(dep[DefaultInfo].default_outputs)

    script = ctx.actions.write(
        "run.sh",
        cmd_args(
            "#!/usr/bin/env bash",
            "set -euo pipefail",
            cmd_args("exec", "uv", "run", ctx.attrs.main, *outputs, "\"$@\"", delimiter = " "),
        ),
        is_executable = True,
    )

    run_args = cmd_args(script)
    run_args.hidden(ctx.attrs.main, *outputs)

    return [
        DefaultInfo(),
        RunInfo(args = run_args),
    ]

run_with_outputs = rule(
    impl = _run_with_outputs_impl,
    attrs = {
        "main": attrs.source(),
        "deps": attrs.list(attrs.dep(), default = []),
    },
)
