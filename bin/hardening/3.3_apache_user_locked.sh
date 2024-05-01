#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 3.3 Ensure the Apache User Account Is Locked
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Apache User Account Is Locked"

# This function will be called if the script status is on enabled / audit mode
audit() {
	APACHE_USER=$($APACHE2CTLBIN  -t -D DUMP_RUN_CFG | grep "^User:" | sed -E 's/.*name="([^"]+)".*/\1/')
	APACHE_LOCKED_ACCOUNT=$( passwd -S "$APACHE_USER" | cut -f 2 -d" ")

	if [ "$APACHE_LOCKED_ACCOUNT" = "L" ]; then
		ok "Apache account is locked"
	else
		crit "Apache account must be locked"
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
