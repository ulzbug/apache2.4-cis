#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 12.3 Ensure Apache AppArmor Profile is in Enforce Mode
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure Apache AppArmor Profile is in Enforce Mode"

# This function will be called if the script status is on enabled / audit mode
audit() {
	check_apparmor

	if [ "$FNRET" = 0 ]; then
		APACHE2_PROFILES=$(aa-unconfined --paranoid | grep "/usr/sbin/apache2")

		NB_PROFILES=$(echo "$APACHE2_PROFILES" | wc -l)

		if [ "$NB_PROFILES" = 0 ]; then
			crit "No apache2 apparmor profile found"
		else
			IFS=$'\n'
			OK=1
			for PROFILE in $APACHE2_PROFILES; do
				ENFORCE_FOUND=$(echo "$PROFILE" | grep "confined by" | grep "(enforce)" | wc -l)
				if [ "$ENFORCE_FOUND" = 0 ]; then
					crit "Apache2 apparmor profile is not in enforce mode : $PROFILE"
					OK=0
				fi
			done

			if [ "$OK" = 1 ]; then
				ok "All apache2 apparmor profiles are in enforce mode"
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
