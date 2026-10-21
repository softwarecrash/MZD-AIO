#!/bin/sh

SYSTEM_UNAVAILABLE=0
SYSTEM_HDCP_TOGGLE=1
SYSTEM_SPEED_RESTRICTION_TOGGLE=4
SYSTEM_DEV_MODE_TOGGLE=7
SYSTEM_CPUGAUGE_TOGGLE=10
SYSTEM_DISP_CONFIG_TOGGLE=13
SYSTEM_RESET_MAP=16
SYSTEM_RESET_VIP=17
SYSTEM_USB_DRIVERS=18
SYSTEM_TAUSIM_TOGGLE=19
SYSTEM_TERMINAL=22
SYSTEM_WIFI_AP_TOGGLE=25
SYSTEM_USERTTY_TOGGLE=28
LVDS_SPEED_RESTRICTION_TOGGLE=31
VCF_FILES_TOGGLE=34
DELETE_BDS_FILES_TOGGLE=37
NNG_DEBUG_TOGGLE=40
SYSTEM_HCI_LOG_TOGGLE=43
SYSTEM_NAVIGATE_TOGGLE=46

PROC_RET=1

if [[ "$1" == "--help" ]]; then
        echo "This script is designed to take in a number and run a corresponding scripts"
        echo "It will be used by the architecture and integration team "
        echo "To run the script:"
        echo "./startSystemScripts.sh <num>"
        echo ""
        echo "From CMU Diag screen entering numbers will run this script with <num> as arg"
        echo "This script will call other scripts to either perform a task or prompt the user via a wayland client surface"
fi

case $1 in
	$SYSTEM_UNAVAILABLE)   
		echo "Invalid request"
		;;
	$SYSTEM_HDCP_TOGGLE)   
		value=`cat /sys/class/nvram/nv-config/keys/lvds_hdcp_mode`
		if [[ "$value" == "disable" ]]; then
			/jci/scripts/set_hdcp_config.sh enable
			PROC_RET=2
		else
			/jci/scripts/set_hdcp_config.sh disable
			PROC_RET=3
		fi
		;;
	$SYSTEM_SPEED_RESTRICTION_TOGGLE)   	
		value=`cat /sys/class/nvram/nv-config/keys/bus_bcm_speed_restriction`
		if [[ "$value" == "disable" ]]; then
			/jci/scripts/set_speed_restriction_config.sh enable
			PROC_RET=5
		else
			/jci/scripts/set_speed_restriction_config.sh disable
			PROC_RET=6
		fi
		;;
	$SYSTEM_DEV_MODE_TOGGLE)	
		if [[ -f /data/integration/developer_mode_on_flag ]]; then
			/jci/scripts/developer_mode.sh off
			PROC_RET=9
		else
			/jci/scripts/developer_mode.sh on
			PROC_RET=8
		fi
		;;
	$SYSTEM_CPUGAUGE_TOGGLE)	
		if [[ -f /data/integration/cpugauge_on_flag ]]; then
			/jci/scripts/jci-cpugauge.sh off
			PROC_RET=12
		else
			/jci/scripts/jci-cpugauge.sh on
			PROC_RET=11
		fi
		;;
	$SYSTEM_DISP_CONFIG_TOGGLE)
		value=`cat /sys/class/nvram/nv-config/keys/lvds_display_type`
		if [[ "$value" == "visteon" ]]; then
			/jci/scripts/set_display_config.sh jci
			PROC_RET=15
		else
			/jci/scripts/set_display_config.sh visteon
			PROC_RET=14
		fi
		;;	
	$SYSTEM_RESET_MAP)	
		/jci/scripts/resetmap
		;;
	$SYSTEM_RESET_VIP)	
		/jci/scripts/resetvip
		;;
	$SYSTEM_USB_DRIVERS)	
		/jci/scripts/usb_drivers.sh
		;;
	$SYSTEM_TAUSIM_TOGGLE)	
		if [[ -f /data/integration/tau_connected_sim_on_flag ]]; then
			/jci/scripts/jci-tausim.sh off
			PROC_RET=21
		else
			/jci/scripts/jci-tausim.sh on
			PROC_RET=20
		fi
		;;
	$SYSTEM_TERMINAL)
		/jci/scripts/run-terminal.sh
		;;
	$SYSTEM_WIFI_AP_TOGGLE)
		WIFI_PID=$(pidof hostapd)
		if [[ "$WIFI_PID" == "" ]]; then
			/jci/scripts/jci-wifiap.sh start
			PROC_RET=23
		else
			/jci/scripts/jci-wifiap.sh stop
			PROC_RET=24
		fi
		;;
	$SYSTEM_USERTTY_TOGGLE)
		CONF_FSPEC="/data/log/syslog-ng.conf"
		ELEM=destination
    		DEST=d_usertty
		egrep "^\s+$ELEM\($DEST\);" "$CONF_FSPEC" >/dev/null
		if [[ "$?" == "1" ]]; then
			/jci/scripts/jci-log.sh usertty enable
			PROC_RET=26
		else
			/jci/scripts/jci-log.sh usertty disable
			PROC_RET=27
		fi
		;;
	$LVDS_SPEED_RESTRICTION_TOGGLE)
		value=`cat /sys/class/nvram/nv-config/keys/lvds_speed_restriction`
		if [[ "$value" == "disable" ]]; then
			/jci/scripts/set_lvds_speed_restriction_config.sh enable
			PROC_RET=29
		else
			/jci/scripts/set_lvds_speed_restriction_config.sh disable
			PROC_RET=30
		fi
		;;
	$VCF_FILES_TOGGLE)
		/jci/pb/pbDebugToggle
		if [[ "$?" == "1" ]]; then
			PROC_RET=32
		else
			PROC_RET=33
		fi
		;;
	$DELETE_BDS_FILES_TOGGLE)
		/jci/msg/msgsDebugToggle
		if [[ "$?" == "1" ]]; then
			PROC_RET=35
		else
			PROC_RET=36
		fi
		;;
	$NNG_DEBUG_TOGGLE)
		value=`ls -l /data/debug_options.ini | awk '{print $11}'`
		if [[ "$value" == "/jci/nng/NNG_debugging_OFF.ini" ]]; then
			/jci/scripts/set_nng_debug.sh ON
			PROC_RET=38
		else
			/jci/scripts/set_nng_debug.sh OFF
			PROC_RET=39
		fi
		;;
	$SYSTEM_HCI_LOG_TOGGLE)
		/jci/scripts/set_hci_logging.sh toggle
		if ( `grep -q 'uartsnifferenable="true"' /jci/bds/BdsConfiguration.xml` ); then
			PROC_RET=41
		else
			PROC_RET=42
		fi
		;;
	$SYSTEM_NAVIGATE_TOGGLE)
		/jci/scripts/set_navi_gate_config.sh toggle
		if [[ -f /data/NaviGate.enabled ]]; then
			PROC_RET=44
		else
			PROC_RET=45
		fi
		;;
	*)
esac

exit $PROC_RET

