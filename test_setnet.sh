#!/bin/bash

# a simple script to check if every network conditions
# can be set up by script 'setnet.sh' correctly.

DEBUG=${DEBUG:- }

# *EDGE*
# RTT varying
VARYING_RTT_EDGE="
{
  DESC:  'EDGE, RTT varying',
  RTT:   (800,1350,50),
  DW_BW: 170,
  UP_BW: 86,
  LOSS:  3,
}"
RTT_EDGE="800 855 910 965 1020 1075 1130 1185 1240 1295 1350"
echo "$VARYING_RTT_EDGE"
for rtt in $RTT_EDGE; do
    $DEBUG bash setnet.sh -l 0.03 -d 170 -u 86 -r $rtt
    ipfw pipe show
    sleep 1
done

# Downlink Bandwidth varying
VARYING_DW_BW_EDGE="
{
  DESC:  'EDGE, varying downlink bandwidth',
  DW_BW: (120,220,10),
  RTT:   1000,
  UP_BW: 86,
  LOSS:  3,
}"
DW_BW_EDGE="120 130 140 150 160 170 180 190 200 210 220"
echo "$VARYING_DW_BW_EDGE"
for dw_bw in $DW_BW_EDGE; do
    $DEBUG bash setnet.sh -l 0.03 -u 86 -r 1000 -d $dw_bw
    ipfw pipe show
    sleep 1
done


# *3G*
# RTT varying
VARYING_RTT_3G="
{
  DESC: '3G, varying RTT',
  RTT:   (50,350,30),
  DW_BW: 3584,
  UP_BW: 640,
  LOSS:  3,
}"
RTT_3G="50 80 110 140 170 200 230 260 290 320 350"
echo "${VARYING_RTT_3G}"
for rtt in $RTT_3G; do
    $DEBUG bash setnet.sh -l 0.03 -d 3584 -u 640 -r $rtt
    ipfw pipe show
    sleep 1
done

# Downlink Bandwidth varying
VARYING_DW_BW_3G="
{
  DESC:  '3G, varying downlink bandwidth',
  DW_BW: (1024,6144,512),
  RTT:   200,
  UP_BW: 640,
  LOSS:  3,
}"
DW_BW_3G="1024 1536 2048 2560 3072 3584 4096 4608 5120 5632 6144"
echo "$VARYING_DW_BW_3G"
for dw_bw in $DW_BW_3G; do
    $DEBUG bash setnet.sh -l 0.03 -u 640 -r 200 -d $dw_bw
    ipfw pipe show
    sleep 1
done

# *4G*
VARYING_RTT_4G="
{
  DESC:  '4G, varying rtt',
  RTT:   (20,120,10),
  DW_BW: 12800,
  UP_BW: 7680,
  LOSS:  3,
}"
RTT_4G="20 30 40 50 60 70 80 90 100 110 120"
echo "$VARYING_RTT_4G"
for rtt in $RTT_4G; do
    $DEBUG bash setnet.sh -l 0.03 -d 12800 -u 7680 -r $rtt
    ipfw pipe show
    sleep 1
done

# Downlink Bandwidth varying
VARYING_DW_BW_4G="
{
  DESC:  '4G, varying downlink bandwidth',
  DW_BW: (7168,18432,1024),
  RTT:   72,
  UP_BW: 7680,
  LOSS:  3,
}"
DW_BW_4G="7168  8192  9216  10240  11264  12288  13312  14336  15360  16384  17408  18432"
echo "$VARYING_DW_BW_4G"
for dw_bw in $DW_BW_4G; do
    $DEBUG bash setnet.sh -l 0.03 -u 7680 -r 72 -d $dw_bw
    ipfw pipe show
    sleep 1
done
