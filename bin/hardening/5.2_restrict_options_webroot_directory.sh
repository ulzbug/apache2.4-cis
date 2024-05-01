#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.2 Ensure Options for the Web Root Directory Are Restricted
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Options for the Web Root Directory Are Restricted"

# This function will be called if the script status is on enabled / audit mode
audit() {
	DOCUMENT_ROOT=$("$APACHE2CTLBIN" -t -D DUMP_RUN_CFG | grep "Main DocumentRoot:" | sed "s/Main DocumentRoot: //"| sed 's/"//g')

	CONTENT_ROOT_DIRECTORY=$(grep "^[^#]" /etc/apache2/apache2.conf | tr '\n' ' ' | sed -E "s#.*<Directory $DOCUMENT_ROOT>([^<]*)</Directory>.*#\1#")
	CONTENT_ROOT_DIRECTORY_BEFORE_REPLACE=$(grep "^[^#]" /etc/apache2/apache2.conf | tr '\n' ' ')

	if [ -z "$CONTENT_ROOT_DIRECTORY" ] || [ "$CONTENT_ROOT_DIRECTORY" = "$CONTENT_ROOT_DIRECTORY_BEFORE_REPLACE" ]; then
		crit "Impossible to detect webroot directory ( $DOCUMENT_ROOT ) element in apache2 configuration file"
	else
		CONTAIN_OPTIONS=$(echo "$CONTENT_ROOT_DIRECTORY" | grep -i "Options none" | wc -l)

		if [ "$CONTAIN_OPTIONS" = 0 ]; then
			crit "Directive 'Options none' is not present in the webroot directory element"
		else
			ok "Directive 'Options none' is present in the webroot directory element"
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
