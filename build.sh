#!/bin/bash

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

list_machines()
{
	cd "$SCRIPT_HOME/machine-builders"
    for i in $(ls); do
    	echo "    $i"
    done
}

print_usage()
{
	echo "Usage: $0 <machine-type> [build options]"
	echo
	echo "Where machine-type is one of:"
	eval list_machines
	echo
	echo "To see allowed build options, type $0 <machine-type> -H"
}

MACHINE_TYPE=$1

if [ "X$MACHINE_TYPE" == "X" ] || [ "$MACHINE_TYPE" == "-h" ] || [ "$MACHINE_TYPE" == "-H" ]; then
	print_usage
	exit 1
fi

shift

echo "Creating new instance of $MACHINE_TYPE with args $@"

"$SCRIPT_HOME/machine-builders/$MACHINE_TYPE/build.sh" $@
