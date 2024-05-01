#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.5 Ensure Weak SSL/TLS Ciphers Are Disabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Weak SSL/TLS Ciphers Are Disabled"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_virtualhosts_conf

	IFS=$'\n'
	OK=1
	# shellcheck disable=2153
	for VIRTUALHOST_CONTENT in $VIRTUALHOSTS_CONTENT; do

		VIRTUALHOST=$(echo "$VIRTUALHOST_CONTENT" | cut -f1 -d":")
		CONTENT=$(echo "$VIRTUALHOST_CONTENT" | cut -f2 -d":")

		SSLENGINE_FOUND=$(echo "$CONTENT" | grep "SSLEngine on" | wc -l)
		SSLCIPHERSUITE_FOUND=$(echo "$CONTENT" | grep "SSLCipherSuite" | wc -l)
		SECURE_CIPHERS_FOUND=$(echo "$CONTENT" | grep "SSLCipherSuite $SECURE_CIPHERS" | wc -l)
		SSLHONORCIPHERORDER_FOUND=$(echo "$CONTENT" | grep "SSLHonorCipherOrder" | wc -l)
		SSLHONORCIPHERORDER_ON_FOUND=$(echo "$CONTENT" | grep "SSLHonorCipherOrder On" | wc -l)

		if [ "$SSLENGINE_FOUND" = 0 ]; then
			continue
		fi

		if [ "$SSLCIPHERSUITE_FOUND" = 0 ]; then
			crit "No directive SSLCipherSuite found for vhost $VIRTUALHOST"
			OK=0
		elif [ "$SECURE_CIPHERS_FOUND" = 0 ]; then
			crit "Weak ciphers found for vhosts $VIRTUALHOST"
			OK=0
		elif [ "$SSLHONORCIPHERORDER_FOUND" = 0 ]; then
			crit "No directive SSLHonorCipherOrder found for vhosts $VIRTUALHOST"
			OK=0
		elif [ "$SSLHONORCIPHERORDER_ON_FOUND" = 0 ]; then
			crit "Directive SSLHonorCipherOrder not enabled for vhosts $VIRTUALHOST"
			OK=0
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "All ciphers found are secured"
	fi
}

# This function will check config parameters required
check_config() {
    :
}

# This function will create the config file for this check with default values
create_config() {
    cat <<EOF
status=audit
# Specify LogError value. It should be at least info for the core and notice for other modules
SECURE_CIPHERS=".*:!EXP:!NULL:!LOW:!SSLv2:!RC4:!aNULL"
EOF
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
