#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.7 Ensure HTTP Request Methods Are Restricted
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure HTTP Request Methods Are Restricted"

# This function will be called if the script status is on enabled / audit mode
audit() {
	CONTENT_ALL_DIRECTORIES=$(grep "^[^#]" /etc/apache2/apache2.conf | tr '\n' ' ' | sed 's#<Directory#\n<Directory#ig' | sed -E 's#^[^<][^dD].*##'  | sed -E "s#.*<Directory ([^>]*)>(.*)</Directory>.*#\1:\2#")

	IFS=$'\n'
	OK=1
	for CONTENT_DIRECTORY in $CONTENT_ALL_DIRECTORIES; do
		DIRECTORY=$(echo "$CONTENT_DIRECTORY" | cut -f1 -d":")
		CONTENT=$(echo "$CONTENT_DIRECTORY" | cut -f2 -d":")

		if [ "$DIRECTORY" = "/" ]; then
			continue
		fi

		CONTAIN_LIMITEXCEPT=$(echo "$CONTENT" | grep -i "<LimitExcept" | wc -l)
		if [ "$CONTAIN_LIMITEXCEPT" = 0 ]; then
			crit "No LimitExcept directive found in directory $DIRECTORY"
			OK=0
		else
			# TODO, analyze LimitExcept content to check requests method. Only GET, POST, OPTIONS authorized. Check Require all denied
			:
		fi
	done
	unset IFS

	if [ "$OK" = 1 ]; then
		ok "All directories have restricted request methods"
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
