# Buck2 rules for Terraform

[Buck2](https://buck2.build/) rules for [Terraform](https://developer.hashicorp.com/terraform).

## Usage

Add to your project's `.buckconfig`:

```ini
[cells]
  terraform_rules = terraform_rules

[external_cells]
  terraform_rules = git

[external_cell_terraform_rules]
  git_origin = https://github.com/omarjatoi/buck2-terraform-rules.git
  commit_hash = <commit>
```

and add to `BUCK` file:

```starlark
load("@terraform_rules//terraform:macros.bzl", "terraform_workspace")

terraform_workspace(
    name = "vpc",
    srcs = glob(["**/*.tf"]),
    vars = {"region": "us-east-1"},
)
```

```bash
buck2 build //infra:vpc           # apply and produce outputs.json
buck2 run //infra:vpc-plan        # plan
buck2 run //infra:vpc-validate    # validate
buck2 run //infra:vpc-fmt -- .    # format source files
buck2 run //infra:vpc-destroy     # destroy
```

Other targets can `deps` on `:vpc` to consume its `outputs.json`.

##  License

Licensed under either of

- Apache License, Version 2.0, ([LICENSE-APACHE](./LICENSE-APACHE) or https://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](./LICENSE-MIT) or https://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
