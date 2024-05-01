#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 6.4 Ensure Log Storage and Rotation Is Configured Correctly
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Log Storage and Rotation Is Configured Correctly"

# This function will be called if the script status is on enabled / audit mode
audit() {
	OK=0
	does_pattern_exist_in_file "/etc/logrotate.d/apache2" "daily"
	if [ "$FNRET" = 0 ]; then
		does_pattern_exist_in_file "/etc/logrotate.d/apache2" "rotate 90"
		if [ "$FNRET" = 0 ]; then
			OK=1
			ok "Log storage and rotation is configured correctly"
		fi
	fi

	if [ "$OK" = 0 ]; then
		does_pattern_exist_in_file "/etc/logrotate.d/apache2" "weekly"
		if [ "$FNRET" = 0 ]; then
			does_pattern_exist_in_file "/etc/logrotate.d/apache2" "rotate 13"
			if [ "$FNRET" = 0 ]; then
				OK=1
				ok "Log storage and rotation is configured correctly"
			fi
		fi
	fi

	if [ "$OK" = 0 ]; then
		crit "Log storage and rotation is not configured correctly : keed at least 14 weeks of logs"
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
