#!/bin/sh

enable_speed_restriction()
{
    echo bus_bcm_speed_restriction=enable > /sys/class/nvram/nv-config/add
    echo enable > /sys/class/nvram/nv-config/keys/bus_bcm_speed_restriction
    echo "" > /sys/class/nvram/nv-config/commit
}

disable_speed_restriction()
{
    echo bus_bcm_speed_restriction=disable > /sys/class/nvram/nv-config/add
    echo disable > /sys/class/nvram/nv-config/keys/bus_bcm_speed_restriction
    echo "" > /sys/class/nvram/nv-config/commit
}

if [ "$1" == "enable" ]; then
    echo "Setting BUS_BCM Speed Restriction Configuration to 'enable'"
    enable_speed_restriction
elif [ "$1" == "disable" ]; then
    echo "Setting BUS_BCM Speed Restriction Configuration to 'disable'"
    disable_speed_restriction
else
    echo "Invalid parameter."
    echo "Usage: $0 enable|disable"
fi