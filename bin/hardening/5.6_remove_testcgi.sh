#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.6 Ensure the Default CGI Content test-cgi Script Is Removed
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Default CGI Content test-cgi Script Is Removed"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_all_document_root

	OK=1

	for DOCUMENT_ROOT in $ALL_DOCUMENTS_ROOT; do
		RESULTS=$(find "$DOCUMENT_ROOT" -type f -name test-cgi)
		if [ -n "$RESULTS" ]; then
			crit "File test-cgi has been found in DocumentRoot $DOCUMENT_ROOT"
			OK=0
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "No test-cgi files found in all DocumentRoot directories"
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
