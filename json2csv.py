#!/usr/bin/env python

import sys
import json

RTT_RANGE=range(50, 1001, 50)       # x20
DW_BW_RANGE=range(150, 15151, 500)  # x31


def main(json_file):
    with open(json_file) as f:
        data = json.load(f)
        ds = {}  # holds {'DW150RTT50': '1.2,3.4,2.3,4.1,3.2', ...}
        for x in data:
            dw  = x['net_dw_bw']
            rtt = x['net_rtt']
            res = '"%s"' % ','.join( map(str, x['results']) )
            key = "DW%sRTT%s" % (dw, rtt)
            ds[key] = res

    output = "%s.csv" % json_file
    with open(output, 'w') as of:
        of.write( ",%s\n" % ','.join(map(str, RTT_RANGE)) )
        for i in DW_BW_RANGE:
            of.write('%d,' % i)
            row = ','.join(ds['DW%dRTT%d' % (i,j)] for j in RTT_RANGE )
            of.write(row)
            of.write('\n')

if __name__ == "__main__":
    jsonf = sys.argv[1]
    main(jsonf)
