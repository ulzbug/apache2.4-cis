#!/bin/bash

# run-shellcheck
#
# CIS Debian Hardening
#

#
# 2.2 Ensure the Log Config Module Is Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure the Log Config Module Is Enabled"

MODULE_NAME="log_config"

# This function will be called if the script status is on enabled / audit mode
audit() {
	is_apache2_module_enabled "$MODULE_NAME"
	if [ "$FNRET" = 0 ]; then
		ok "$MODULE_NAME is enabled!"
	elif [ "$FNRET" = 1 ]; then
		crit "$MODULE_NAME is disabled"
	else
		crit "$MODULE_NAME is not installed"
	fi
}

# This function will be called if the script status is on enabled mode
apply() {
	is_apache2_module_enabled "$MODULE_NAME"
	if [ "$FNRET" = 0 ]; then
		ok "$MODULE_NAME is enabled!"
	elif [ "$FNRET" = 1 ]; then
		info "enabling module $MODULE_NAME"
		a2enmod -f $MODULE_NAME
	else
		crit "Module $MODULE_NAME doesn't seem to be installed, you should install it manualy"
	fi
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    # shellcheck source=../../debian/default
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_LIB_DIR" ]; then
    echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
    echo "Cannot source CIS_LIB_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r "${CIS_LIB_DIR}"/main.sh ]; then
    # shellcheck source=../../lib/main.sh
    . "${CIS_LIB_DIR}"/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_LIB_DIR in /etc/default/cis-hardening"
    exit 128
fi
