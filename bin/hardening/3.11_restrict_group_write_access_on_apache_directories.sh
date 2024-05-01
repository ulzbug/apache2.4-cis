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

PERMISSIONS='640'
PERMISSIONSOK='600 640 644 700 750 755'

# This function will be called if the script status is on enabled / audit mode
audit() {
	APACHE_FILES=$(dpkg -L apache2)

	for APACHE_FILE in $APACHE_FILES; do
		if [ -f "$APACHE_FILE" ] && [ ! -L "$APACHE_FILE" ]; then
			has_file_one_of_permissions "$APACHE_FILE" "$PERMISSIONSOK"
			if [ "$FNRET" = 0 ]; then
				ok "$APACHE_FILE has correct permissions"
			else
				crit "$APACHE_FILE permissions were not set to $PERMISSIONS"
			fi
		fi
	done
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
