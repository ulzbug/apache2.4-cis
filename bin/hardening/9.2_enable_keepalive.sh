#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 9.2 Ensure KeepAlive Is Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure KeepAlive Is Enabled"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	KEEPALIVE_FOUND=$(echo "$APACHE2_CONF" | grep -Ei "KeepAlive\s+on" | wc -l)

	if [ "$KEEPALIVE_FOUND" = 0 ]; then
		crit "Keepalive is not enabled"
	else
		ok "Keepalive is enabled"
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
