## ANXS - python

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/anxs/python/github-workflow-molecule.yml)
![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)

Ansible role which installs python, pip, virtualenv, and uv

#### Requirements & Dependencies
- Tested on Ansible 2.12 or higher.

#### Variables

```yaml
python_setuptools_version:    # default to latest
python_virtualenv_version:    # default to latestlenv
```

## Testing

This project uses molecule to test a few scenarios. You can kick off the tests (and linting) with `make test`.

## License

Licensed under the MIT License. See the [LICENSE](https://github.com/ANXS/python/blob/master/LICENSE) file for details.

## Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/python/issues)!
