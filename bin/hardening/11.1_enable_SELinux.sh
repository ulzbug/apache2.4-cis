#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 11.1 Ensure SELinux Is Enabled in Enforcing Mode
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure SELinux Is Enabled in Enforcing Mode"

# This function will be called if the script status is on enabled / audit mode
audit() {
	check_selinux

	if [ "$FNRET" = 0 ]; then
		ok "SELinux is installed"

		SELINUX_MODE=$(sestatus | grep -i "mode" | grep -i "enforcing" | wc -l)

		if [ "$SELINUX_MODE" = 0 ]; then
			crit "SELinux is not in enforced mode"
		else
			ok "SELinux is in enforced mode"
		fi
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
