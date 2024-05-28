#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.9 Ensure Old HTTP Protocol Versions Are Disallowed
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Old HTTP Protocol Versions Are Disallowed"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_virtualhosts_conf

	DISALLOW_HTTP1_FOUND=$(echo "$OUTSIDE_VIRTUALHOST_CONF" | grep -iE "RewriteEngine\s*On\s*RewriteCond\s*%{THE_REQUEST}\s*\!HTTP/1\\\.1\\$\s*RewriteRule\s*\.\* - [F]" | wc -l)
	if [ "$DISALLOW_HTTP1_FOUND" = 0 ]; then
		crit "Old HTTP protocol versions are not disallowed"
	else
		ok "Old HTTP protocol versions are disallowed"
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
