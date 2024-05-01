#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.15 Ensure the IP Addresses for Listening for Requests Are Specified
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure the IP Addresses for Listening for Requests Are Specified"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	LISTEN_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i 'Listen' | sed -e 's/^[[:space:]]*//')

	IFS=$'\n'
	OK=1
	for LISTEN in $LISTEN_OCCURENCES; do
		IP=$(echo "$LISTEN" | cut -f2 -d" ")
		PORT=$(echo "$LISTEN" | cut -f3 -d" ")

		if [ -z "$PORT" ]; then
			OK=0
			crit "This Listen directive does not specify the IP address : $LISTEN"
		elif [ "$IP" = "0.0.0.0" ] || [ "$IP" = "[::ffff:0.0.0.0]" ]; then
			OK=0
			crit "This Listen directive listen on all IP addresses : $LISTEN"
		fi
	done
	unset IFS

	if [ "$OK" = 1 ]; then
		ok "All Listen directives specify an ip address"
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
