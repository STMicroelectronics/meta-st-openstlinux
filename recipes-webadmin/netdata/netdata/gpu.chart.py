# -*- coding: utf-8 -*-
# Description: gpu netdata python.d module
# Author:
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import os
import re
import time
from subprocess import Popen, PIPE

from bases.FrameworkServices.SimpleService import SimpleService

update_every = 4
priority = 90000

ORDER = [
    'usage',
]

CHARTS = {
    'usage': {
        'options': [None, 'Usage', 'percent', 'usage', None, 'line'],
        'lines': [
            ['usage', None, 'absolute', 1, 100]
        ]
    },
}


def getpipeoutput(cmds):
    p = Popen(cmds[0], stdout = PIPE, shell = True)
    processes=[p]
    for x in cmds[1:]:
        p = Popen(x, stdin = p.stdout, stdout = PIPE, shell = True)
        processes.append(p)
    output = p.communicate()[0]
    for p in processes:
        p.wait()
    return output.decode('utf-8').rstrip('\n')


class Service(SimpleService):
    def __init__(self, configuration=None, name=None):
        SimpleService.__init__(self, configuration=configuration, name=name)
        self.order = ORDER
        self.definitions = CHARTS
        self._orig_name = ""
        self.sysfs_on = 0
        self.sysfs_start = 0

    def check(self):
        return True

    def _get_data(self):
        data = 0.0
        result = getpipeoutput(["cat /sys/kernel/debug/gc/idle"]).split('\n')
        for line in result:
            parts = line.split(' ')
            subline = " ".join(parts[1:]).replace(" ", "")
            subline = re.sub("ns", "", subline, flags=re.UNICODE)
            subline = re.sub(",", "", subline, flags=re.UNICODE)
            if parts[0] == "On:":
                on = int(subline)
            if parts[0] == "Off:":
                off = int(subline)
            if parts[0] == "Idle:":
                idle = int(subline)
            if parts[0] == "Suspend:":
                suspend = int(subline)
        data = float( (on - self.sysfs_on) * 100 / (on + off + idle + suspend - self.sysfs_start) )

        self.sysfs_on = on
        self.sysfs_start = on + off + idle + suspend
        return { 'usage': int(data * 100) }

