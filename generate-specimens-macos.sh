#!/bin/bash
#
# Script to generate Unified Logging and Activity Tracing test files
# Requires macOS

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1;

	which ${BINARY} > /dev/null 2>&1;
	if test $? -ne ${EXIT_SUCCESS};
	then
		echo "Missing binary: ${BINARY}";
		echo "";

		exit ${EXIT_FAILURE};
	fi
}

assert_availability_binary log;
assert_availability_binary hdiutil;
assert_availability_binary sw_vers;

MACOS_VERSION=`sw_vers -productVersion`;

SPECIMENS_PATH="specimens/${MACOS_VERSION}";

if test -d ${SPECIMENS_PATH};
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists.";

	exit ${EXIT_FAILURE};
fi

mkdir -p ${SPECIMENS_PATH};

set -e;

DEVICE_NUMBER=`diskutil list | grep -e '^/dev/disk' | tail -n 1 | sed 's?^/dev/disk??;s? .*$??'`;

# Create a logarchive of the last hour.
sudo log collect --last 1h --output ${SPECIMENS_PATH}/unified-logging.logarchive

hdiutil create -srcfolder ${SPECIMENS_PATH}/unified-logging.logarchive -format UDZO ${SPECIMENS_PATH}/unified-logging.logarchive

sudo log show --style json --timezone UTC --backtrace --debug --info --loss --signpost --archive ${SPECIMENS_PATH}/unified-logging.logarchive > ${SPECIMENS_PATH}/unified-logging.logarchive.json

rm -rf ${SPECIMENS_PATH}/unified-logging.logarchive

exit ${EXIT_SUCCESS};

