#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.3 Ensure the Server's Private Key Is Protected
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Server's Private Key Is Protected"

USER="root"
GROUP="root"
PERMISSIONS="400"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	SSL_CERTIFICATE_KEY_FILE_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i "SSLCertificateKeyFile ")

	for SSL_CERTIFICATE_FILE_OCCURENCE in $SSL_CERTIFICATE_KEY_FILE_OCCURENCES; do
		CERTIFICATE_KEY_FILE=$(echo "$SSL_CERTIFICATE_FILE_OCCURENCE"  | sed 's/SSLCertificateKeyFile//' |  sed 's/\s//g')

		has_file_correct_ownership "$CERTIFICATE_KEY_FILE" "$USER" "$GROUP"
		if [ "$FNRET" = 0 ]; then
			ok "$CERTIFICATE_KEY_FILE has correct ownership"
		else
			crit "$CERTIFICATE_KEY_FILE ownership was not set to $USER:$GROUP"
		fi

        has_file_correct_permissions "$CERTIFICATE_KEY_FILE" "$PERMISSIONS"
        if [ "$FNRET" = 0 ]; then
            ok "$CERTIFICATE_KEY_FILE permissions were set to $PERMISSIONS"
        else
            crit "$CERTIFICATE_KEY_FILE permissions were not set to $PERMISSIONS"
        fi
	done
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
