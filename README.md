## [ANXS](http://anxs.io/) - python

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/anxs/python/github-workflow-molecule.yml)
![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/anxs/python)
![GitHub License](https://img.shields.io/github/license/anxs/python)

Ansible role which installs python, pip, virtualenv, and uv

## Requirements & Dependencies

* Tested on Ansible 2.12 or higher.

## Variables

This is a partial listing of configurable variables

* `python_versions` is a list of python versions to install from the [deadsnakes](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) PPA.
* `python_uv_version` can be set to `true` to install [uv](https://github.com/astral-sh/uv).

## Testing

This project uses molecule to test a few scenarios. You can kick off the tests (and linting) with `make test`.

## Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/python/issues)!
