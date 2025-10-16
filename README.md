## ANXS - python

[![test workflow status](https://github.com/ANXS/python/actions/workflows/test.yml/badge.svg)](https://github.com/ANXS/python/actions/workflows/test.yml) ![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)

Ansible role which installs python, pip, and virtualenv

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
