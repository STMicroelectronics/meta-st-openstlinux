# -*- coding: utf-8 -*-
# Description: gpu netdata python.d module
# Author:
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import os
import re
from subprocess import Popen, PIPE

from base import SimpleService

update_every = 5
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

    def check(self):
        return True

    def _get_data(self):
        data = 0.0
        result = getpipeoutput(["cat /sys/kernel/debug/gc/idle"]).split('\n')
        for line in result:
            parts = line.split(' ')
            subline = " ".join(parts[1:]).replace(" ", "")
            subline = re.sub("ns", "", subline, flags=re.UNICODE)
            if parts[0] == "Start:":
                start = int(subline)
            if parts[0] == "End:":
                stop = int(subline)
            if parts[0] == "On:":
                on = int(subline)
        data = float(on * 100 / (stop - start) )
        return { 'usage': int(data)*100 }

    def create(self):
        self.chart_name = "gpu"
        status = SimpleService.create(self)
        self.chart_name = self._orig_name
        return status

    def update(self, interval):
        self.chart_name = "gpu"
        status = SimpleService.update(self, interval=interval)
        self.chart_name = self._orig_name
        return status
