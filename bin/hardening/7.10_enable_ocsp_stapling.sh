#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.10 Ensure OCSP Stapling Is Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure OCSP Stapling Is Enabled"

SSLSTAPLINGCACHE_ACCEPTED_VALUES="shmcb:logs/ssl_staple_cache(512000) dbm:logs/ssl_staple_cache.db dc:UNIX:logs/ssl_staple_socket"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	SSLUSESTAPLING_FOUND=$(echo "$APACHE2_CONF" | grep -i 'SSLUseStapling' | wc -l)
	SSLUSESTAPLING_ON_FOUND=$(echo "$APACHE2_CONF" | grep -i 'SSLUseStapling\s+on' | wc -l)
	SSLUSESTAPLING_OFF_FOUND=$(echo "$APACHE2_CONF" | grep -i 'SSLUseStapling\s+off' | wc -l)

	if [ "$SSLUSESTAPLING_FOUND" = 0 ]; then
		crit "No directive SSLUseStapling found"
	elif [ "$SSLUSESTAPLING_OFF_FOUND" = 0 ]; then
		crit "Directive SSLUseStapling found but is disabled ( value off )"
	elif [ "$SSLUSESTAPLING_ON_FOUND" = 1 ]; then
		ok "Directive SSLUseStapling enabled"
	else
		warn "Directive SSLUseStapling : unknown value"
	fi

	OK=0
	for SSLSTAPLINGCACHE_ACCEPTED_VALUE in $SSLSTAPLINGCACHE_ACCEPTED_VALUES; do
		SSLSTAPLINGCACHE_FOUND=$(echo "$APACHE2_CONF" | grep -i "SSLStaplingCache \"$SSLSTAPLINGCACHE_ACCEPTED_VALUE\"" | wc -l)
		SSLSTAPLINGCACHE_FOUND2=$(echo "$APACHE2_CONF" | grep -i "SSLStaplingCache $SSLSTAPLINGCACHE_ACCEPTED_VALUE" | wc -l)

		if [ "$SSLSTAPLINGCACHE_FOUND" -gt 0 ] || [ "$SSLSTAPLINGCACHE_FOUND2" -gt 0 ]; then
			OK=1
			break
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "Directive SSLStaplingCache correctly configured"
	else
		crit "Directive SSLStaplingCache not correctly configured"
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
