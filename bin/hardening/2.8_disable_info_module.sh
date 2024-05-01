#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 2.8 Ensure the Info Module Is Disabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Info Module Is Disabled"

MODULE_REGEX="info_module"
MODULE_NAME="info_module"

# This function will be called if the script status is on enabled / audit mode
audit() {
	is_apache2_module_enabled "$MODULE_REGEX"
	if [ "$FNRET" = 0 ]; then
		warn "$MODULE_NAME is enabled, disable it if you don't need. Keep it of you use it ( for example if you use php-fpm )"
	else
		ok "$MODULE_NAME is disabled or not installed"
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
