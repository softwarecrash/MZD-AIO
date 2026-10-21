#!/bin/sh

##### VARS
RESET_FLAG="/data/perform_factory_reset"

##### FUNCTIONS
print_usage() {
    echo "$0" >&2
    echo "This sets the factory reset flag. When the"
    echo "board boots next time, all data will be cleared."
    echo
    echo "Factory reset flag: $RESET_FLAG"
    echo
    echo "options:"
    echo "  -r    restart after setting factory reset flag"
    echo "  -c    clears the factory reset flag"
    echo
}

##### PARSE ARGS
do_resetboard=false
do_factory_reset=true
do_clear=false
while getopts "rhc" OPTION
do
    case $OPTION in
    r)
        do_resetboard=true
    ;;
    c)
        do_factory_reset=false
        do_clear=true
    ;;
    h)
        print_usage
        exit 0
    ;;
    [?])
        print_usage
        exit 1
    ;;
    esac
done
shift $(($OPTIND-1))

# Check the resetboard flag; if set, reboot.
if $do_factory_reset; then touch $RESET_FLAG; fi

# Clear the factor reset flag
if $do_clear; then rm -f $RESET_FLAG 2>/dev/null; fi

# Check the resetboard flag; if set, reboot.
if $do_resetboard; then sync; resetboard; fi

exit 0;