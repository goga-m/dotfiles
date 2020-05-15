#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
$active = $(xrandr --query | grep " connected" | cut -d" " -f1)

MONITOR=$active
polybar --reload standard &