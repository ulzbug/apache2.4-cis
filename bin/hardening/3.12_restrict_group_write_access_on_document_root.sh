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

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_all_document_root

	APACHE_GROUP=$($APACHE2CTLBIN  -t -D DUMP_RUN_CFG | grep "^Group:" | sed -E 's/.*name="([^"]+)".*/\1/')

	for DOCUMENT_ROOT in $ALL_DOCUMENTS_ROOT; do
		if [ -d "$DOCUMENT_ROOT" ]; then
			FILE_WRITABLE=$(find -L "$DOCUMENT_ROOT" -group "$APACHE_GROUP" -perm /g=w -ls)
			if [ -n "$FILE_WRITABLE" ]; then
				crit "Directory $DOCUMENT_ROOT contains files or directories writable by group"
			else
				ok "Directory $DOCUMENT_ROOT has correct permissions"
			fi
		else
			warn "Directory $DOCUMENT_ROOT is present in configuration file, but doesn't exist"
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
