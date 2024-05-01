#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.4 Ensure the TLSv1.0 and TLSv1.1 Protocols are Disabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the TLSv1.0 and TLSv1.1 Protocols are Disabled"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	SSL_PROTOCOL_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i "SSLProtocol")

	IFS=$'\n'
	OK=1
	for SSL_PROTOCOL_OCCURENCE in $SSL_PROTOCOL_OCCURENCES; do
		SSL_PROTOCOL=$(echo "$SSL_PROTOCOL_OCCURENCE"  | sed 's/SSLProtocol//' |  sed 's/^\s*//g' |  sed 's/\s*$//g')

		if [ "$SSL_PROTOCOL" != "TLSv1.2 TLSv1.3" ] && [ "$SSL_PROTOCOL" != "TLSv1.3" ] && [ "$SSL_PROTOCOL" != "all -SSLv3 -TLSv1 -TLSv1.1" ] && [ "$SSL_PROTOCOL" != "all -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2" ]; then
			crit "Old tls protocols are not disabled : $SSL_PROTOCOL"
			OK=0
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "All old tls protcols are disabled"
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
