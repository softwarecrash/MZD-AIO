#!/bin/sh

echo $1
if [[ "$1" == "--help" ]]; then
        echo "This script is designed to take in a number and run a corresponding scripts"
        echo "It will be used by the architecture and integration team "
        echo "To run the script:"
        echo "./startSystemScripts.sh <num>"
        echo ""
        echo "From CMU Diag screen entering numbers will run this script with <num> as arg"
        echo "This script will call other scripts to either perform a task or prompt the user via a wayland client surface"
else
	if [[ "$1" == "11" ]]; then
		/jci/tools/jci-systemDialog &
	else
        	echo "Currently only '11' is being used, you typed " $1
	fi
fi
