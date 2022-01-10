# Contributing

Each action will be a subdirectory underneath the `actions` directory using dashes to separate words.  The action then can be referrenced in the form: `shopsmart/github-actions/actions/${workflow-id}.yml`.

Actions should *NOT* checkout unless it is a crucial part of the action.  By insisting that the caller of the action do the checkout, the caller can fully control the source code/version of their code in their workflows rather than depend on every parameter to be passed into an action.

Actions that run logic in a shell (more than a few lines) should put that shellscript into a descriptive file and contain a test file alongside it.  We will use [BATS](https://bats-core.readthedocs.io/en/stable/) as the testing suite for shellscripts.

Shell scripts should have an extension of `.sh` and BATS test files have an extension of `.bats`.

Along with a BATS test, each action should contain a workflow in the form `test-${workflow-id}.yml` which calls the action code, ensuring at the very least, that the action is properly callable.
