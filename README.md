## ANXS - python [![Build Status](https://travis-ci.org/ANXS/python.png)](https://travis-ci.org/ANXS/python)

Ansible role which installs python, pip, setuptools and virtualenv


#### Requirements & Dependencies
- Tested on Ansible 1.4 or higher.


#### Variables

```yaml
python_setuptools_version:    # default to latest
python_virtualenv_version:    # default to latestlenv
```


#### Testing
This project comes with a VagrantFile, this is a fast and easy way to test changes to the role, fire it up with `vagrant up`

See [vagrant docs](https://docs.vagrantup.com/v2/) for getting setup with vagrant


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/python/issues)!
