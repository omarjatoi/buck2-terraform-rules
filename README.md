# Buck2 rules for Terraform

[Buck2](https://buck2.build/) rules for [Terraform](https://developer.hashicorp.com/terraform).

## Usage

```starlark
load("@terraform_rules//terraform:macros.bzl", "terraform_workspace")

terraform_workspace(
    name = "vpc",
    srcs = glob(["**/*.tf"]),
    vars = {"region": "us-east-1"},
)
```

```bash
buck2 run //infra:vpc-plan        # plan
buck2 run //infra:vpc-apply       # apply (interactive)
buck2 run //infra:vpc-validate    # validate
buck2 run //infra:vpc-fmt -- .    # format source files
buck2 run //infra:vpc-output      # read outputs
buck2 run //infra:vpc-destroy     # destroy
```

Set `auto_approve = True` on the workspace for CI.

##  License

Licensed under either of

- Apache License, Version 2.0, ([LICENSE-APACHE](./LICENSE-APACHE) or https://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](./LICENSE-MIT) or https://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
