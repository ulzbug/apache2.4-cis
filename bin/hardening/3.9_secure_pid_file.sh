#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 3.5 Ensure the Group Is Set Correctly on Apache Directories and Files
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Group Is Set Correctly on Apache Directories and Files"

USER='root'
GROUP='root'
PERMISSIONS='644'
PERMISSIONSOK='600 640 644'

# This function will be called if the script status is on enabled / audit mode
audit() {
	PID_FILE=$(grep "^PidFile" /etc/apache2/apache2.conf | sed "s/PidFile //")
	# shellcheck disable=2016
	if [ "$PID_FILE" = '${APACHE_PID_FILE}' ]; then
		PID_FILE=$(grep "^export APACHE_PID_FILE=" /etc/apache2/envvars | sed "s/export APACHE_PID_FILE=//" | sed 's/$SUFFIX//')
	fi

	DOCUMENT_ROOT=$("$APACHE2CTLBIN" -t -D DUMP_RUN_CFG | grep "Main DocumentRoot:" | sed "s/Main DocumentRoot: //"| sed 's/"//g')
	IS_PID_FILE_IN_DOCUMENT_ROOT=$(echo "$PID_FILE" | grep -F "$DOCUMENT_ROOT" | wc -l)

	if [ "$IS_PID_FILE_IN_DOCUMENT_ROOT" = "0" ]; then
		ok "$PID_FILE is within the document root"
	else
		crit "$PID_FILE is not within the document root"
	fi

	has_file_correct_ownership "$PID_FILE" "$USER" "$GROUP"
	if [ "$FNRET" = 0 ]; then
		ok "$PID_FILE has correct ownership"
	else
		crit "$PID_FILE ownership was not set to $USER:$GROUP"
	fi

	has_file_one_of_permissions "$PID_FILE" "$PERMISSIONSOK"
	if [ "$FNRET" = 0 ]; then
		ok "$PID_FILE has correct permissions"
	else
		crit "$PID_FILE permissions were not set to $PERMISSIONS"
	fi
}


# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/apache2-cis-hardening ]; then
    # shellcheck source=../../debian/default
    . /etc/default/apache2-cis-hardening
fi
if [ -z "$CIS_LIB_DIR" ]; then
    echo "There is no /etc/default/apache2-cis-hardening file nor cis-hardening directory in current environment."
    echo "Cannot source CIS_LIB_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r "${CIS_LIB_DIR}"/main.sh ]; then
    # shellcheck source=../../lib/main.sh
    . "${CIS_LIB_DIR}"/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_LIB_DIR in /etc/default/apache2-cis-hardening"
    exit 128
fi
