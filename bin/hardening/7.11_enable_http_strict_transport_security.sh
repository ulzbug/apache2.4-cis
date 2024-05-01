#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.11 Ensure HTTP Strict Transport Security Is Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure HTTP Strict Transport Security Is Enabled"

# This function will be called if the script status is on enabled / audit mode
audit() {

	get_virtualhosts_conf

	HSTS_FOUND=$(echo "$OUTSIDE_VIRTUALHOST_CONF" | grep -i "Header always set Strict-Transport-Security \"max-age=(\d+)\"" | wc -l)

	if [ "$HSTS_FOUND" -ge 1 ]; then
		ok "Strict-Transport-Security found in server level configuration"

		HSTS_MAX_AGE=$(echo "$OUTSIDE_VIRTUALHOST_CONF" | grep -io "Header always set Strict-Transport-Security \"max-age=(\d+)\"" | grep -o '\d+')
		if [ "$HSTS_MAX_AGE" -ge 480 ]; then
			ok "Server level configuration : Strict-Transport-Security max age is greater than 480"
		else
			crit "Server level configuration : Strict-Transport-Security max age is lower than 480"
		fi
	else
		crit "Strict-Transport-Security not found in server level configuration"
	fi

	IFS=$'\n'
	OK=1
	# shellcheck disable=2153
	for VIRTUALHOST_CONTENT in $VIRTUALHOSTS_CONTENT; do
		VIRTUALHOST=$(echo "$VIRTUALHOST_CONTENT" | cut -f1 -d":")
		CONTENT=$(echo "$VIRTUALHOST_CONTENT" | cut -f2 -d":")

		HSTS_FOUND=$(echo "$CONTENT" | grep -i "Header always set Strict-Transport-Security \"max-age=(\d+)\"" )
		HSTS_MAX_AGE=$(echo "$CONTENT" | grep -io "Header always set Strict-Transport-Security \"max-age=(\d+)\"" | grep -o '\d+' )

		if [ "$HSTS_FOUND" = 0 ]; then
			crit "VirtualHost $VIRTUALHOST : Strict-Transport-Security not found"
			OK=0
		elif [ "$HSTS_MAX_AGE" -lt 480 ]; then
			crit "VirtualHost $VIRTUALHOST : Strict-Transport-Security max age is lower than 480"
			OK=0
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "Strict-Transport-Security found in every virtual host and has a max-age greater than 480"
	fi
}

# This function will check config parameters required
check_config() {
    is_pkg_installed "curl"
    if [ "$FNRET" != 0 ]; then
        warn "Curl is not installed, can't verify this check"
        exit 2
    fi
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
