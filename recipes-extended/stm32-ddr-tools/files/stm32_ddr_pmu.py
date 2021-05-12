#!/usr/bin/python3

import getopt
import re
import sys

with open('/proc/device-tree/compatible', 'r') as compatible:
    if 'stm32mp15' in compatible.read():
        word_length  = 4    # Bytes
    else:
        word_length  = 2    # Bytes

burst_length = 8    # Words

def usage():
    print("Usage:")
    print("  python stm32_ddr_pmu.py [-d <ddr_freq>] -f <perf_file>")
    print("    -d ddr_freq: DDR frequency in MHz (533 MHz by default)")
    print("    -f perf_file: text file containing the output of")
    print("        perf stat -e stm32_ddr_pmu/read_cnt/,stm32_ddr_pmu/time_cnt/,stm32_ddr_pmu/write_cnt/ -a -o <perf_file> <command>")
    print("The script considers bursts of %s words with %s bytes per word." % (burst_length, word_length))
    sys.exit(2)

ddr_freq = 533
perf_file = None
dic = {}

try:
    opts, args = getopt.getopt(sys.argv[1:], "d:f:")
except getopt.GetoptError:
    print("Error: invalid option !")
    usage()

for opt,arg in opts:
    if opt == '-d':
        ddr_freq = int(arg)
    elif opt == '-f':
        perf_file = arg
    else:
        usage()

if perf_file == None:
    print("Error: no perf file !")
    usage()

with open(perf_file) as file:
    lines = file.readlines()
    for line in lines:
        a = re.match(".* ([0-9]+).*stm32_ddr_pmu\/(.*)\/.*", line)
        try:
            dic[a.groups()[1]] = a.groups()[0]
        except:
            continue

constant = word_length * burst_length * ddr_freq * 1000000 / int(dic['time_cnt']) / (1024 * 1024)
read_bw = int(dic['read_cnt']) * constant
write_bw = int(dic['write_cnt']) * constant

print("R = %s MB/s, W = %s MB/s, R&W = %s MB/s (DDR @ %s MHz)" % (read_bw.__round__(),
      write_bw.__round__(), (read_bw + write_bw).__round__(), ddr_freq))
