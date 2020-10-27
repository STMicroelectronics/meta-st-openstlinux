# due to a chnage os behaviour between dunfell 3.1.0 and 3.1.1 for python3
# module, we need to differenciate the package:
# apt-get install python3-misc (on dunfell 3.1.1 image with package from 3.1.0)
# trying to overwrite '/usr/lib/python3.8/__pycache__/pathlib.cpython-38.opt-1.pyc', which is also in package python3-core 3.8.2-r0

PR = "r1"
