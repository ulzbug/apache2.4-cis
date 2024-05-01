#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 9.6 Ensure Timeout Limits for the Request Body is Set to 20 or Less
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Timeout Limits for the Request Body is Set to 20 or Less"

MODULE_NAME="reqtimeout_module"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	is_apache2_module_enabled "$MODULE_NAME"
	if [ "$FNRET" != 0 ]; then
		crit "$MODULE_NAME is not enabled!"
	else
		REQUESTREADTIMEOUT_FOUND=$(echo "$APACHE2_CONF" | grep -Ei "RequestReadTimeout.*body=([0-9-]+)" | wc -l)

		if [ "$REQUESTREADTIMEOUT_FOUND" = 0 ]; then
			ok "RequestReadTimeout directive not found"
		else
			REQUESTREADTIMEOUT=$(echo "$APACHE2_CONF" | grep -i "RequestReadTimeout" | grep -oEi "body=[0-9-]+" | grep -oEi "[0-9-]+")

			REQUESTREADTIMEOUT_VALUE_FOUND=$(echo "$REQUESTREADTIMEOUT" | grep -oEi "^[0-9]+-([0-9]+)$" | wc -l)

			if [ "$REQUESTREADTIMEOUT_VALUE_FOUND" -gt 0 ]; then
				REQUESTREADTIMEOUT_VALUE=$(echo "$REQUESTREADTIMEOUT" | grep -oEi "^[0-9]+-([0-9]+)$" | grep -oEi '[0-9]+' | tail -n 1)
				if [ "$REQUESTREADTIMEOUT_VALUE" -le 40 ] && [ "$REQUESTREADTIMEOUT_VALUE" -gt 0 ]; then
					ok "RequestReadTimeout is present and lesser than 40"
				else
					crit "RequestReadTimeout is present but greater than 40"
				fi
			else
				REQUESTREADTIMEOUT_VALUE2=$(echo "$REQUESTREADTIMEOUT" | grep -oEi "^([0-9]+)$")

				if [ "$REQUESTREADTIMEOUT_VALUE2" -le 40 ] && [ "$REQUESTREADTIMEOUT_VALUE2" -gt 0 ]; then
					ok "RequestReadTimeout is present and lesser than 40"
				else
					crit "RequestReadTimeout is present but greater than 40"
				fi
			fi
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
