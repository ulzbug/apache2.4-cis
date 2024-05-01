#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.16 Ensure Browser Framing Is Restricted
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure Browser Framing Is Restricted"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	CONTENT_SECURITY_POLICY_SELF_FOUND=$(echo "$APACHE2_CONF" | grep -i 'Header always append Content-Security-Policy "frame-ancestors '\''self'\''"' | wc -l)
	CONTENT_SECURITY_POLICY_NONE_FOUND=$(echo "$APACHE2_CONF" | grep -i 'Header always append Content-Security-Policy "frame-ancestors '\''none'\''"' | wc -l)
	X_FRAME_OPTIONS_FOUND=$(echo "$APACHE2_CONF" | grep -i 'Header always set X-Frame-Options SAMEORIGIN' | wc -l)

	if [ "$CONTENT_SECURITY_POLICY_SELF_FOUND" = 1 ]; then
		ok "Browser framing is restricted with header Content-Security-Policy \"frame-ancestors self\""
	elif [ "$CONTENT_SECURITY_POLICY_NONE_FOUND" = 1 ]; then
		ok "Browser framing is restricted with header Content-Security-Policy \"frame-ancestors none\""
	elif [ "$X_FRAME_OPTIONS_FOUND" = 1 ]; then
		ok "Browser framing is restricted with header X-Frame-Options SAMEORIGIN"
	else
		crit "Browser framing is not restricted"
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
