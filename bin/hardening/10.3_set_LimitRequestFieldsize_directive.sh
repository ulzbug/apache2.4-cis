#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 10.3 Ensure the LimitRequestFieldsize Directive is Set to 1024 or Less
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure the LimitRequestFieldsize Directive is Set to 1024 or Less"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	LIMITREQUESTFIELDSIZE_FOUND=$(echo "$APACHE2_CONF" | grep -Ei "LimitRequestFieldsize\s+([0-9]+)" | wc -l)

	if [ "$LIMITREQUESTFIELDSIZE_FOUND" = 0 ]; then
		crit "LimitRequestFieldsize directive not found"
	else
		LIMITREQUESTFIELDSIZE=$(echo "$APACHE2_CONF" | grep -Eoi "LimitRequestFieldsize\s+([0-9]+)")

		if [ "$LIMITREQUESTFIELDSIZE" -le 1024 ] && [ "$LIMITREQUESTFIELDSIZE" -gt 0 ]; then
			ok "LimitRequestFieldsize is present and lesser than 1024"
		else
			crit "LimitRequestFieldsize is present but greater than 1024"
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
