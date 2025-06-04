#!/usr/bin/python3

import getopt
import re
import sys
import os

def found_perf():
    prefix = "/proc/device-tree"
    for root, dirs, files in os.walk(prefix):
        for d in dirs:
            if 'perf@' in d:
                return (os.path.join(root, d))
    return None

def get_clock_rate(clock):
    # first search clock in stm32_clk_summary
    if os.path.isfile('/sys/kernel/debug/clk/stm32_clk_summary'):
        clk_re = re.compile(r"^ *%s *([0-9]+) *(Y|N)" % clock)
        with open('/sys/kernel/debug/clk/stm32_clk_summary', 'r') as stm32_clk_summary:
            for line in stm32_clk_summary:
                mo = clk_re.match(line)
                if mo:
                    return int(mo.group(1))

    # if stm32_clk_summary does not exist or clock not found in stm32_clk_summary,
    # look for clock existence in clk framework
    clk_rate_filename = '/sys/kernel/debug/clk/%s/clk_rate' % clock
    if os.path.isfile(clk_rate_filename):
        with open(clk_rate_filename, 'r') as clk_rate:
            return int(clk_rate.readline().strip())

    return None

with open('/proc/device-tree/compatible', 'r') as compatible:
    compatible_string = compatible.read()
    if 'stm32mp15' in compatible_string:
        word_length  = 4    # Bytes
        burst_length = 8    # Words
        ddr_freq = 533
        ddr_type = 'DDR'
        divider = 1
        clock_name = 'pll2_r'
    elif 'stm32mp13' in compatible_string:
        word_length  = 2    # Bytes
        burst_length = 8    # Words
        ddr_freq = 533
        ddr_type = 'DDR'
        divider = 1
        clock_name = 'pll2_r'
    elif 'stm32mp2' in compatible_string:
        if 'stm32mp25' in compatible_string:
            # 32 bits
            word_length  = 4    # Bytes
            ddr_freq = 1200
        if 'stm32mp23' in compatible_string:
            # 16 bits
            word_length  = 2    # Bytes
            ddr_freq = 1200
        if 'stm32mp21' in compatible_string:
            # 16 bits
            word_length  = 2    # Bytes
            ddr_freq = 800
        burst_length = 8    # Words
        ddr_type = 'DDR'
        divider = 8
        clock_name = 'ck_pll2'
        try:
            devicetree_path = found_perf()
            if devicetree_path is None:
                print("ERROR: Cannot find perf entry on /proc/device-tree/soc* (%s)" % "perf@xxxxxxxx")
                sys.exit(1)
            with open("%s/st,dram-type" % devicetree_path, 'rb') as tmp:
                t = int.from_bytes(list(tmp.read(4)), byteorder='big', signed=False)
                if t == 0:
                    ddr_type = 'LPDDR4'
                    burst_length = 16
                elif t == 1:
                    ddr_type = 'LPDDR3'
                elif t == 2:
                    ddr_type = 'DDR4'
                elif t == 3:
                    ddr_type = 'DDR3'
        except:
            print("Warning: cannot detect DDR type from devicetree; use defaults")
    else:
        print("ERROR: Cannot detect SoC from devicetree")
        sys.exit(1)

def usage():
    print("Usage:")
    print("  python stm32_ddr_pmu.py -f <perf_file> [-d <ddr_freq>] [-w <word_length>] [-l <burst_length>]")
    print("    -h: print this help")
    print("    -d ddr_freq: DDR frequency in MHz (%s MHz by default)" % ddr_freq)
    print("    -w word_length: width in bytes of DDR bus (%s by default)" % word_length)
    print("    -l burst_length: length in cycles of DDR burst (%s by default)" % burst_length)
    print("    -f perf_file: text file containing the output of a perf stat command")
    print("")
    print("        MP1: perf stat -e stm32_ddr_pmu/perf_op_is_rd/,\\")
    print("                          stm32_ddr_pmu/perf_op_is_wr/,\\")
    print("                          stm32_ddr_pmu/time_cn/t -C 0 -o <perf_file> <command>")
    print("")
    print("        MP2: perf stat -e stm32_ddr_pmu/dfi_is_rd/,\\")
    print("                          stm32_ddr_pmu/dfi_is_wr/,\\")
    print("                          stm32_ddr_pmu/dfi_is_rda/,\\")
    print("                          stm32_ddr_pmu/dfi_is_wra/,\\")
    print("                          stm32_ddr_pmu/dfi_is_mwra/,\\")
    print("                          stm32_ddr_pmu/dfi_is_mwr/,\\")
    print("                          stm32_ddr_pmu/time_cnt/ -C 0 -o <perf_file> <command>")
    print("")
    print("The script considers bursts of %s words with %s bytes per word." % (burst_length, word_length))
    sys.exit(2)

perf_file = None
dic = {}

clk_rate = get_clock_rate(clock_name)
if clk_rate:
    clk_rate /= 1000000
    if 'stm32mp2' in compatible_string:
        clk_rate *= 2
    print("Found ddr frequency of %s MHz" % clk_rate)
    ddr_freq = clk_rate
else :
    print('Warning: cannot find ddr clock summary entry, fallback to default value else specified')

try:
    opts, args = getopt.getopt(sys.argv[1:], "hd:f:w:l:")
except getopt.GetoptError:
    print("Error: invalid option !")
    usage()

for opt,arg in opts:
    if opt == '-d':
        ddr_freq = int(arg)
    elif opt == '-f':
        perf_file = arg
    elif opt == '-w':
        word_length = int(arg)
    elif opt == '-l':
        burst_length = int(arg)
    elif opt == '-h':
        usage()

if len(opts) == 0:
    usage()

if perf_file == None:
    print("Error: no perf file !")
    usage()

with open(perf_file) as file:
    lines = file.readlines()
    for line in lines:
        a = re.match(" *([0-9]+) *stm32_ddr_pmu/(.*)/", line)
        try:
            dic[a.groups()[1]] = a.groups()[0]
        except:
            continue

constant = word_length * burst_length * ddr_freq * 1000000 / int(dic['time_cnt']) / (1024 * 1024) / divider
if 'stm32mp1' in compatible_string:
    read_event = int(dic['perf_op_is_rd'])
    write_event = int(dic['perf_op_is_wr'])
elif 'stm32mp2' in compatible_string:
    read_event = int(dic['dfi_is_rd']) + int(dic['dfi_is_rda'])
    write_event = int(dic['dfi_is_wr']) + int(dic['dfi_is_wra'])

if 'LPDDR' in ddr_type:
    try:
        write_event = write_event + int(dic['dfi_is_mwr']) + int(dic['dfi_is_mwra'])
    except:
        pass

read_bw = read_event * constant
write_bw = write_event * constant

print("R = %s MB/s, W = %s MB/s, R&W = %s MB/s (%s @ %s MHz)" % (read_bw.__round__(),
      write_bw.__round__(), (read_bw + write_bw).__round__(), ddr_type, ddr_freq))
