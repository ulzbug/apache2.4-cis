#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 8.3 Ensure All Default Apache Content Is Removed
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure All Default Apache Content Is Removed"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	is_apache2_module_enabled "autoindex_module"
	AUTOINDEX_MODULE="$FNRET"

	is_apache2_module_enabled "alias_module"
	ALIAS_MODULE="$FNRET"

	DIRECTORY_ICONS_FOUND=$(echo "$APACHE2_CONF" | grep "<Directory\s+\"/usr/share/apache2/icons\">" | wc -l)

	if [ "$AUTOINDEX_MODULE" = 0 ] && [ "$ALIAS_MODULE" = 0 ]; then
		ok "autoindex and alias modules are disabled!"
	elif [ "$DIRECTORY_ICONS_FOUND" = 0 ]; then
		ok "No icons directory found"
	else
		crit "Autoindex and alias modules are enable. /usr/share/apache2/icons is available"
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
