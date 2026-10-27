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
    'plane',
]

#          name, title, units, family, context, charttype
#   unique_dimension_name, name, algorithm, multiplier, divisor
CHARTS = {
    'plane': {
        'options': [None, 'Plane', 'fps', 'plane', 'fps.plane', 'line'],
        'lines': [
        ]
    },
}
def getpipeoutput(cmds):
    p = Popen(cmds[0], stdout = PIPE, shell = True)
    processes=[p]
    for x in cmds[1:]:
        p = Popen(x, stdin = p.stdout, stdout = PIPE, shell = True)
        processes.append(p)
    output, error_out = p.communicate()
    for p in processes:
        p.wait()
    return output.decode().rstrip('\n')


class Service(SimpleService):
    def __init__(self, configuration=None, name=None):
        SimpleService.__init__(self, configuration=configuration, name=name)
        self.order = ORDER
        self.definitions = CHARTS

    def check(self):
        return True

    def get_data(self):
        try:
            data = dict()

            if os.path.exists("/dev/dri/card0"):
                result = getpipeoutput(["sudo cat /sys/kernel/debug/dri/0/state", "grep '[pu][ls][ae][nr][e_]'" , "grep -v mask", "grep -v changed"]).split('\n')
            else:
                return None
            name = None
            plane_fps = None
            for line in result:
                if re.search('plane', line):
                    name = line.split('[')[1].split(']')[0]
                if re.search('user_updates=', line):
                    plane_fps = line.split('=')[1].split('f')[0]
                    if name is not None:
                        dimension_id = 'plane_{}'.format(int(name))
                        if dimension_id not in self.charts['plane']:
                            self.charts['plane'].add_dimension([dimension_id, dimension_id, 'absolute', 1, 1])
                            #self.charts['plane'].add_dimension([dimension_id])
                        data[dimension_id] = int(plane_fps)

            return data
        except Exception as e:
            return None

