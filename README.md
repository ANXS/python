## [ANXS](https://github.com/ANXS) - python

[![CI Status](https://img.shields.io/github/actions/workflow/status/anxs/python/ci.yml)](https://github.com/ANXS/python/actions/workflows/ci.yml)
[![Maintenance](https://img.shields.io/maintenance/yes/2026.svg)](https://github.com/ANXS/python)
[![Ansible Role](https://img.shields.io/ansible/role/d/anxs/python)](https://galaxy.ansible.com/ui/standalone/roles/ANXS/python/)
[![License](https://img.shields.io/github/license/ANXS/python)](https://github.com/ANXS/python/blob/master/LICENSE)

Ansible role for installing Python 3, pip, and virtualenv from system packages, with optional support for additional Python versions via the [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) and the [uv](https://github.com/astral-sh/uv) package manager.

## Requirements & Dependencies

* Ansible 2.13 or higher.
* Ubuntu 22.04+ or Debian 12+.

## Variables

Two commonly adjusted variables. See [`defaults/main.yml`](https://github.com/ANXS/python/blob/master/defaults/main.yml) for the full set.

* `python_versions` (default empty list) is a list of additional Python versions to install from the deadsnakes PPA.
* `python_uv_install` (default false) to install `uv` package manager.

## Testing

Tests use [Molecule](https://github.com/ansible/molecule) with Docker and [Testinfra](https://testinfra.readthedocs.io/). Run the full suite with `make test`, or target a specific platform (e.g. `make test-ubuntu2404`).

The test suite covers Python 3 and pip package installation, virtualenv creation, uv binary installation and architecture detection, and file permissions. Tests run across all supported Linux distributions.

## Note on AI Usage

This project has been developed with AI assistance. Contributions making use of AI generated content are welcome, however they _must_ be human reviewed prior to submission as pull requests, or issues. All contributors must be able to fully explain and defend any AI generated code, documentation, issues, or tests they submit. Contributions making use of AI must have this explicitly declared in the pull request or issue. This also applies to utilization of AI for reviewing of pull requests.

## Feedback, bug-reports, requests, ...

Are all [welcome](https://github.com/ANXS/python/issues)!
