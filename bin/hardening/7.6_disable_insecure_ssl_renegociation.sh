#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.6 Ensure Insecure SSL Renegotiation Is Not Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Insecure SSL Renegotiation Is Not Enabled"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	SSL_INSECURE_RENEGOTIATION_FOUND=$(echo "$APACHE2_CONF" | grep -i "SSLInsecureRenegotiation" | wc -l)
	SSL_INSECURE_RENEGOTIATION_ON_FOUND=$(echo "$APACHE2_CONF" | grep -i "SSLInsecureRenegotiation\son" | wc -l)

	if [ "$SSL_INSECURE_RENEGOTIATION_FOUND" = 0 ]; then
		ok "No directive SSLInsecureRenegotiation found"
	elif [ "$SSL_INSECURE_RENEGOTIATION_FOUND" = 1 ] && [ "$SSL_INSECURE_RENEGOTIATION_ON_FOUND" = 0 ]; then
		ok "SSLInsecureRenegotiation is not enabled"
	else
		crit "SSLInsecureRenegotiation is enabled"
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
