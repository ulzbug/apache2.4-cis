#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.4 Ensure Default HTML Content Is Removed
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Default HTML Content Is Removed"

# This function will be called if the script status is on enabled / audit mode
audit() {
	DOCUMENT_ROOT=$("$APACHE2CTLBIN" -t -D DUMP_RUN_CFG | grep "Main DocumentRoot:" | sed "s/Main DocumentRoot: //"| sed 's/"//g')

	if [ ! -f "$DOCUMENT_ROOT/index.html" ]; then
		ok "index.html doesn't exist in document root"
	else
		CONTAIN_DEFAULT_CONTENT=$(grep -i "Apache2 Debian Default Page" "$DOCUMENT_ROOT/index.html" | wc -l)

		if [ "$CONTAIN_DEFAULT_CONTENT" = 0 ]; then
			ok "Default content has been removed from default index.html"
		else
			crit "$DOCUMENT_ROOT/index.html contains default content"
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
